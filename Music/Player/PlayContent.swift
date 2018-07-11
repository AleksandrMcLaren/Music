//
//  PlayContent.swift
//  Music
//
//  Created by Aleksandr on 02.02.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation

class PlayContent {

    /// Статус проигрывания
    var playing: Bool = false {
        didSet {
            postNotification()
        }
    }
    /// Текущее время проирывания
    var currentTime: Float64 = 0 {
        didSet {
            postNotification()
        }
    }
    /// Длительность текущего трека
    var currentDuration: Float64 = 0 {
        didSet {
            postNotification()
        }
    }

    var repeatMode: KeepUpAudioPlayerRepeatMode = .off {
        didSet {
            postNotification()
        }
    }

    var shuffleMode: KeepUpAudioPlayerShuffleMode = .off {
        didSet {
            postNotification()
        }
    }

    /// Треки выбранного content
    var tracks: [DBTrack]?

    /** Объект для воспроизведения.
        Пример возможных объектов: DBAlbum, массив DBTrack.
        Список треков для DBAlbum берется из DBAlbum. */
    let object: AnyObject

    /// Трек для проигрывания объекта content
    var currentTrack: DBTrack {
        didSet {
            postNotification()
        }
    }

    /// Инициализировать с контентом и треком
    init(with object: AnyObject, playTrack: DBTrack) {
        self.object = object
        self.currentTrack = playTrack
        self.createTracks()
    }

    fileprivate func createTracks() {
        if let obj = object as? ObjectExistTracks,
            let list = obj.tracks?.array as? [DBTrack] {
            tracks = list
        } else if let obj = object as? [DBTrack] {
            tracks = obj
        } else if let obj = object as? DBTrack {
            tracks = [obj]
        }
    }

    /// Индекс текущего трека
    var currentTrackIndex: Int {
        get {
            var index = 0

            if let list = tracks,
                list.contains(currentTrack) {
                index = list.index(of: currentTrack) ?? 0
            }

            return index
        }
        set(newIndex) {
            if let tracks = self.tracks,
                newIndex < tracks.count {
                currentTrack = tracks[newIndex]
            }
        }
    }
}

extension PlayContent {

    static let changed = NSNotification.Name("PlayContentChanged")

    fileprivate func postNotification() {
        NotificationCenter.default.post(name: PlayContent.changed, object: self)
    }
}
