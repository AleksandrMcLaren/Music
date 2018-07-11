//
//  Player.swift
//  Music
//
//  Created by Aleksandr on 01.02.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation
import MediaPlayer

/** Класс для управления аудио плеером.
    Содержит методы проверки проигрывания и контента */

let player = MusicPlayer.shared

protocol MusicPlayerPresentable: class {
    /// Для вопроизведения нужно присвоить значение playContent и вызвать play()
    var playContent: PlayContent? { get set }
    /** Для вопроизведения нужно присвоить значение playContent и вызвать play()
        После pause() можно вызвать play() без инициализации playContent */
    func play()
    /// Пауза
    func pause()
    /// Следующий трек
    func playNext()
    /// Предыдущий трек
    func playPrevious()
    /// Перемотка позиции трека
    func seek(to position: Float64)
    /// Включает повтор. Вид повтора регулируется от количества вызовов метода.
    func setRepeatMode()
    /// Включает шафл
    func setShuffleMode()

    /// Текущее состояние проигрывания
    var playing: Bool { get }
    /// Проверка играет ли сейчас этот object
    func playingContentObject(_ object: AnyObject?) -> Bool
}

class MusicPlayer: NSObject, MusicPlayerPresentable {

    static let shared: MusicPlayerPresentable = MusicPlayer()

    private override init() {
        super.init()

        pthread_mutex_init(&content_mutex, nil)

        configurePlayer()
    }

    deinit {
        pthread_mutex_destroy(&content_mutex)
    }

    /// Плеер
    var audioPlayer: KeepUpAudioPlayerPresentable = KeepUpAudioPlayer()
    /// По флагу при вызове play() будет сигнал открыть мини плеер
    fileprivate var isFirstStart: Bool = false
    /// По флагу для воспроизведения возьмет новые данные
    fileprivate var needsPlayNewContent: Bool  = false

    fileprivate var repeateMode: KeepUpAudioPlayerRepeatMode = .off
    fileprivate var shuffleMode: KeepUpAudioPlayerShuffleMode = .off

    // MARK: MusicPlayerPresentable

    fileprivate var content_mutex = pthread_mutex_t()
    fileprivate var _playContentValue: PlayContent?
    var playContent: PlayContent? {
        get {
            pthread_mutex_lock(&content_mutex)
            let content = _playContentValue
            defer {
                pthread_mutex_unlock(&content_mutex)
            }
            return content
        }
        set {
            pthread_mutex_lock(&content_mutex)

            needsPlayNewContent = true

            if _playContentValue == nil {
                isFirstStart = true
            }

            _playContentValue = newValue
            pthread_mutex_unlock(&content_mutex)
        }
    }

    func play() {

        if needsPlayNewContent {
            needsPlayNewContent = false

            if isFirstStart == true {
                isFirstStart = false
                NotificationCenter.default.post(name: MiniPlayerNeedsOpenNotificationName, object: self)
            }

            playNewContent()

        } else {
            audioPlayer.play()
        }
    }

    func pause() {
        audioPlayer.pause()
    }

    func playNext() {
        audioPlayer.playNext()
    }

    func playPrevious() {
        audioPlayer.playPrevious()
    }

    func seek(to position: Float64) {
        audioPlayer.seek(to: position)
    }

    func setRepeatMode() {

        var repeatMode = audioPlayer.repeatMode

        if repeatMode == .off {
            repeatMode = .once
        } else if repeatMode == .once {
            repeatMode = .on
        } else {
            repeatMode = .off
        }

        audioPlayer.repeatMode = repeatMode
    }

    func setShuffleMode() {

        var shuffleMode = audioPlayer.shuffleMode

        if shuffleMode == .off {
            shuffleMode = .on
        } else {
            shuffleMode = .off
        }

        audioPlayer.shuffleMode = shuffleMode
    }

    var playing: Bool {
        return playContent?.playing ?? false
    }

    func playingContentObject(_ object: AnyObject?) -> Bool {

        if object == nil {
            return false
        }

        if let content = playContent {

            if content.playing == false {
                return false
            }

            if content.object === object {
                return content.playing
            }
        }

        return false
    }

    // MARK: -

    /// для нового контента fetch
    fileprivate func playNewContent() {
        var lastItemIndex = 0

        if let tracksCount = playContent?.tracks?.count, tracksCount > 0 {
            lastItemIndex = tracksCount - 1
        }

        audioPlayer.setLastItemIndex(lastItemIndex)
        audioPlayer.fetchItemsAndPlay(at:  playContent?.currentTrackIndex ?? 0)
    }

    fileprivate func configurePlayer() {

        audioPlayer.itemAtIndex = { [weak self] (index, addItem) in
            self?.urlAtIndex(index, completion: { (url) in
                addItem(url)
            })
        }

        audioPlayer.onState = { [unowned self] state in
            self.playContent?.currentTime = state.currentTime
            self.playContent?.currentDuration = state.currentDuration
            self.playContent?.currentTrackIndex = state.currentIndex
            self.playContent?.playing = state.needsPlaying
            self.playContent?.repeatMode = state.repeatMode
            self.playContent?.shuffleMode = state.shuffleMode
            print("index", state.currentIndex,
                  "  play", state.needsPlaying,
                  "  duration", state.currentDuration, state.currentTime,
                  "  repeatMode", state.repeatMode,
                  "  shuffleMode", state.shuffleMode,
                  "  meta", state.timedMetadataValue)

            if let track = self.playContent?.currentTrack {
                MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                    MPMediaItemPropertyTitle: track.name ?? "",
                    MPMediaItemPropertyAlbumTitle: track.album?.name ?? "",
                    MPMediaItemPropertyArtist: track.peoplesList ?? "",
                    MPMediaItemPropertyPlaybackDuration: state.currentDuration,
                    MPNowPlayingInfoPropertyElapsedPlaybackTime: state.currentTime
                ]
            }

//            if let artwork = artwork {
//                MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: artwork)
//            }

        }
    }

    fileprivate func urlAtIndex(_ index: Int, completion: ((_ url: URL) -> Void)?) -> Void {

        /** Если даже есть url, необходимо вызвать Player().getStreamingLink.
            Сервер увеличит счетчик онлайн прослушиваний */

        // TODO: доделать, с сервера должен приходить сразу full link трека

        guard let obj = playContent, let tracks = obj.tracks, index < tracks.count
            else { return }

        var track = tracks[index]

        // track.link = "http://kcell-music.enaza.ru/tank3/universal/00602567549086/00602567549086_T4_audtrk.mp3"
        // http://www.abstractpath.com/files/audiosamples/sample.mp3
        // http://www.abstractpath.com/files/audiosamples/perfectly.wav
        func setupTrack(_ track: DBTrack, at index: Int) -> (Bool) {
            if let link = track.link, let url = URL(string: link) {
                completion?(url)
                return true
            }

            return false
        }

        var setup = setupTrack(track, at: index)

        Player().getStreamingLink(track) { (changed) in
            if setup == false {
                setup = setupTrack(track, at: index)

                if setup == false {
                    let url = NSURL()
                    completion?(url as URL)
                }
            }
        }
    }

}
