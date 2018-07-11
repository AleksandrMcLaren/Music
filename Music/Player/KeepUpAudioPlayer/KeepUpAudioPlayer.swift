//
//  KeepUpAudioPlayer.swift
//  Music
//
//  Created by Aleksandr on 06.02.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

protocol KeepUpAudioPlayerPresentable {

    /** Установка последнего индекса.
        URL по индексам будут запрошены в itemAtIndex: */
    func setLastItemIndex(_ index: Int)
    /** Вызывает проигрывание очереди URL с нужного индекса.
        URL будет запрошен в itemAtIndex: */
    func fetchItemsAndPlay(at index: Int)
    /// Items с зарузками кэшируются для ускорения повторного запуска. Метод удаляет кэш items.
    func removeItems()

    /// Плеер запрашивает URL по индексу. Вернуть URL.
    var itemAtIndex: ((_ index: Int, @escaping ((_ addItem: URL) -> Void)) -> Void)? { get set }

    /// Плеер передает состояние
    var onState: ((PlayerState) -> Swift.Void)? { get set }

    /// Повтор
    var repeatMode: KeepUpAudioPlayerRepeatMode { get set }
    /// Шафл
    var shuffleMode: KeepUpAudioPlayerShuffleMode { get set }

    /// Плей после паузы
    func play()
    /// Пауза
    func pause()
    /// Воспроизвести следующий item
    func playNext()
    /// Воспроизвести предыдущий item. Если item первый, произойдет перемотка на начало item.
    func playPrevious()
    /// Перемотка позиции в item
    func seek(to position: Float64)
}

enum KeepUpAudioPlayerRepeatMode: Int {
    case off
    case once
    case on
}

enum KeepUpAudioPlayerShuffleMode: Int {
    case off
    case on
}

class KeepUpAudioPlayer: NSObject, KeepUpAudioPlayerPresentable {

    override init() {
        super.init()

        pthread_mutex_init(&shuffle_mode_mutex, nil)

        behavior.player = self

        configureAudioSession()
        configureRemoteCommandCenter()
        addPlayerObservers()
        addQueuePlayerObservers()
        configureReachability()
    }

    deinit {
        removeAllItems()
        removeQueuePlayerObservers()
        removePlayerObservers()

        pthread_mutex_destroy(&shuffle_mode_mutex)
    }

    public var queuePlayer: AVQueuePlayer!

    fileprivate var items = [URL: Int]()
    fileprivate var playerItems = [Int: AVPlayerItem]()
    var shufflePlayedIndexes = [Int]()
    var lastItemIndex: Int = 0
    fileprivate var timeObserverPlayer: Any?
    fileprivate var prepareingItemHash: Int = 0
    fileprivate var apReachability: KPReachability?
    fileprivate var behavior = PlayerBehavior()
    fileprivate let queue = DispatchQueue(label: "com.keep.up.audio.player") // DispatchQueue.main
    fileprivate var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid

    fileprivate var shuffle_mode_mutex = pthread_mutex_t()
    fileprivate var _shuffleModeValue: KeepUpAudioPlayerShuffleMode = .off

    fileprivate var _state: Atomic = Atomic(value: PlayerState())
    var state: PlayerState {
        get { return _state.value }
        set { _state.value = newValue }
    }

    // MARK: AudioPlayerPresentable

    var itemAtIndex: ((Int, @escaping ((URL) -> Void)) -> Void)?
    var onState: ((PlayerState) -> Swift.Void)?

    func setLastItemIndex(_ index: Int) {
        queue.async {
            self.lastItemIndex = index
        }
    }

    func fetchItemsAndPlay(at index: Int) {
        queue.async {
            assert(self.lastItemIndex >= 0, "You didn't implement setLastItemIndex:")
            assert(self.itemAtIndex != nil, "You didn't implement needsAddItemAtIndex:")

            if index == (self.playerCurrentIndex() + 1), self.queuePlayer.items().count > 1 {
                self.queuePlayer.advanceToNextItem()
            } else {
                self.removeAllItems()
                self.fetchItemAtIndex(index)
            }

            self.state.reset()
            self.state.currentIndex = index
            self.state.needsPlaying = true
            self.onPlayerState()
        }
    }

    func removeItems() {
        queue.async {
            self.items.removeAll()
            self.playerItems.removeAll()
        }
    }

    func play() {
        queue.async {

            if self.playerCurrentIndex() == self.lastItemIndex,
                self.queuePlayer.items().count == 0,
                let lastUrl = self.items.url(at: self.lastItemIndex) {
                /// очередь уже закончилась и включили последний item через плей, добавим item
                self.addQueueItem(lastUrl, with: self.lastItemIndex)
            }

            self.state.needsPlaying = true
            self.onPlayerState()
            self.queuePlayer.play()
        }
    }

    func pause() {
        queue.async {
            self.queuePlayer.pause()
            
            self.state.needsPlaying = false
            self.onPlayerState()
        }
    }

    func seek(to position: Float64) {
        self.state.lock = true
        self.state.currentTime = position

        queue.async {
            let time = CMTimeMakeWithSeconds(position, 1)
            self.queuePlayer.seek(to: time, completionHandler: { [weak self] (finished) in
                self?.state.lock = false
            })
        }
    }

    func playNext() {
        queue.async {
            
            if self.behavior.repeatModeOnce() == true {
                return
            }

            if self.behavior.shuffleModeOn(playNow: true) == true {
                return
            }

            if self.behavior.repeatModeOn() == true {
                return
            }

            let index = self.playerCurrentIndex()

            if index < self.lastItemIndex {
                self.fetchItemsAndPlay(at: index + 1)
            }
        }
    }

    func playPrevious() {
        queue.async {

            if self.behavior.repeatModeOnce() == true {
                return
            }

            if self.behavior.previousShuffleModeOn() == true {
                return
            }

            let index = self.playerCurrentIndex()

            if index == 0 {
                self.seek(to: 0)
            } else {
                self.fetchItemsAndPlay(at: index - 1)
            }
        }
    }

    fileprivate var _repeatMode: Atomic = Atomic(value: KeepUpAudioPlayerRepeatMode.off)
    var repeatMode: KeepUpAudioPlayerRepeatMode {
        get { return _repeatMode.value }
        set { _repeatMode.value = newValue }
    }

    var shuffleMode: KeepUpAudioPlayerShuffleMode {
        get {
            pthread_mutex_lock(&shuffle_mode_mutex)
            let value = _shuffleModeValue
            defer {
                pthread_mutex_unlock(&shuffle_mode_mutex)
            }
            return value
        }
        set {
            pthread_mutex_lock(&shuffle_mode_mutex)
            _shuffleModeValue = newValue

            if _shuffleModeValue == .off {
                queue.async {
                    self.shufflePlayedIndexes.removeAll()

                    if self.state.needsPlaying == true {
                        /// подгрузим следующий по списку трек
                        let index = self.playerCurrentIndex()
                        if index < self.lastItemIndex {
                            self.fetchItemAtIndex(index + 1)
                        }
                    }
                }
            } else {
                queue.async {
                    if self.state.needsPlaying == true {
                        if let currentUrl = self.queuePlayer.currentItem?.url,
                            let index = self.items[currentUrl] {
                            /// текущий item попадает в список воспроизведенных в режиме шафл
                            if self.shufflePlayedIndexes.contains(index) == false {
                                self.shufflePlayedIndexes.append(index)
                            }
                        }
                    }
                }
            }

            pthread_mutex_unlock(&shuffle_mode_mutex)
        }
    }

    // MARK: - Flow Control

    fileprivate func createQueuePlayer() {
        queuePlayer.removeAllItems()
        removeQueuePlayerObservers()
        queuePlayer = AVQueuePlayer()
        queuePlayer.automaticallyWaitsToMinimizeStalling = false
        addQueuePlayerObservers()
    }

    fileprivate func addQueueItem(_ url: URL, with index: Int) {

        if queuePlayer.status == .failed {
            createQueuePlayer()
        }

        if let playerItem = findPlayerItem(with: url, at: index) {
            playerItem.seek(to: kCMTimeZero, completionHandler: { [weak self] (finished) in
                self?.insertPlayerItem(playerItem, with: index)
            })
        } else {
            let asset = AVURLAsset(url: url) // AVAsset(url: url)
        //    asset.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
          //  let tracks = asset.tracks
            let playerItem = AVPlayerItem(asset: asset)
            //playerItem.preferredForwardBufferDuration = 1
            insertPlayerItem(playerItem, with: index)
        }
    }

    fileprivate func insertPlayerItem(_ item: AVPlayerItem, with index: Int) {

        if queuePlayer.items().count > 1 {
            for i in 1..<queuePlayer.items().count {
                let item = queuePlayer.items()[i]
                item.asset.cancelLoading()
                queuePlayer.remove(item)
            }
        }

        if queuePlayer.canInsert(item, after: nil) {
            queuePlayer.insert(item, after: nil)
            playerItems[index] = item
        }
    }

    fileprivate func removeAllItems() {

        for playerItem in self.queuePlayer.items() {
            playerItem.asset.cancelLoading()
        }

        queuePlayer.removeAllItems()
        items.removeAll()
    }

    fileprivate func findPlayerItem(with url: URL, at index: Int) -> AVPlayerItem? {

        var playerItem: AVPlayerItem?

        if let item = playerItems[index] {
            if let itemUrl = item.url,
                itemUrl == url,
                item.status == .readyToPlay {
                playerItem = item
            }
        }

        return playerItem
    }

    /// Проверяет наличие следующего item. Если его нет подгружает следующий item.
    fileprivate func prepareNextItemIfNeeded() {

        if state.currentTime >= state.currentDuration,
            queuePlayer.items().count < 2 {

            if behavior.shuffleModeOn(playNow: false) == true {
                return
            }

            prepareNextItem()
        }
    }

    /// Подготавливает следующий item
    fileprivate func prepareNextItem() {

        if behavior.shuffleModeOn(playNow: false) == true {
            return
        }

        let nextIndex = playerCurrentIndex() + 1

        if nextIndex <= lastItemIndex {
            fetchItemAtIndex(nextIndex)
        }
    }

    /** Если есть queuePlayer.currentItem, очередь не закончилась, метод вернет индекс item очереди.
        Если очередь закончилась, метод вернет индекс состояния */
    func playerCurrentIndex() -> (Int) {

        var currentIndex = 0

        if let url = queuePlayer.currentItem?.url,
            let index = self.items[url] {
            currentIndex = index
        } else {
            currentIndex = state.currentIndex
        }

        return currentIndex
    }

    /// Продолжает воспроизведение с сохраненного состояния playerState
    fileprivate func resumePlay() {

        if queuePlayer.status == .failed {
            createQueuePlayer()
        }

        let currentIndex = playerCurrentIndex()
        guard let currentUrl = items.url(at: currentIndex) else {
            /// нет url для текущего индекса, запросим url
            fetchItemAtIndex(currentIndex)
            return
        }

        if state.currentTime >= state.currentDuration {
            /// текущий item закончил играть, включим следующий item
            self.prepareNextItem()
            return
        }

        if let playerItem = self.findPlayerItem(with: currentUrl, at: currentIndex) {
            /// продолжим воспроизведение текущего item
            let currentTime = CMTimeMake(Int64(state.currentTime), 1)
            playerItem.seek(to: currentTime, completionHandler: { [weak self] (finished) in
                self?.insertPlayerItem(playerItem, with: currentIndex)
                self?.play()
            })

        } else {
            /// запросим url по индексу
            fetchItemAtIndex(currentIndex)
        }
    }

    fileprivate func didPlayToEndTime() {

        let connected = apReachability?.isConnectedToNetwork

        queue.async {

            if self.behavior.repeatModeOnce() == true {
                return
            }

            if self.shuffleMode == .on {
                if connected == true {
                    self.prepareNextItemIfNeeded()
                }

                return
            }

            if self.behavior.repeatModeOn() == true {
                return
            }

            if self.playerCurrentIndex() == self.lastItemIndex,
                self.state.currentTime >= self.state.currentDuration {
                /// закончил играть последний item
                self.pause()
                return
            }

            if connected == true {
                self.prepareNextItemIfNeeded()
            }
        }
    }

    fileprivate func playbackStalled() {
        queue.async {

            if self.behavior.repeatModeOnce() == true {
                return
            }

            if self.behavior.shuffleModeOn(playNow: true) == true {

                if self.repeatMode == .off,
                    self.shufflePlayedIndexes.count == (self.lastItemIndex + 1),
                    self.state.needsPlaying == true {
                    /// упал, не смог доиграть до конца последний item
                    /// behavior.shuffleModeOn не выключил потому что не доиграл до конца
                    /// выключим
                    self.pause()
                    self.shufflePlayedIndexes.removeAll()
                }

                return
            }

            if self.behavior.repeatModeOn() == true {
                return
            }

            if self.playerCurrentIndex() == self.lastItemIndex,
                self.state.currentTime >= self.state.currentDuration {
                /// закончил играть последний item
                self.pause()
                return
            }

            if self.state.needsPlaying == true {
                /// закончился буфер, пробуем возобновить
                self.resumePlay()
            }
        }
    }

    /** Плеер проходит и сбрасывает очередь если кончился буфер, например без интернета.
        currentItem есть, значит идет воспроизаедение.
        Если needsPlaying=true и нет currentItem или rate=0 продолжим воспроизведение */
    fileprivate func resumePlayIfNeeded() {
        if state.needsPlaying == true {
            if queuePlayer.currentItem == nil || queuePlayer.rate == 0 {
                resumePlay()
            }
        }
    }

    func fetchItemAtIndex(_ index: Int) {
        DispatchQueue.main.async {
            self.itemAtIndex?(index, { [weak self] (url) in
                self?.queue.async {
                    self?.items[url] = index
                    self?.addQueueItem(url, with: index)
                }
            })
        }
    }

    fileprivate func onPlayerState() {
        DispatchQueue.main.async {
            if self.state.lock == false {
                self.onState?(self.state)
            }
        }
    }

    // MARK: Configure

    fileprivate func configureAudioSession() {

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(true)
        } catch {
            print("Error. \(String(describing: type(of: self))) \(#function): \(error)")
        }

        queuePlayer = AVQueuePlayer()
        queuePlayer.automaticallyWaitsToMinimizeStalling = false
    }

    fileprivate func configureRemoteCommandCenter() {

        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget(handler: { [weak self] (_) in
            self?.play()
            return MPRemoteCommandHandlerStatus.success
        })

        commandCenter.pauseCommand.addTarget(handler: { [weak self] (_) in
            self?.pause()
            return MPRemoteCommandHandlerStatus.success
        })

        commandCenter.nextTrackCommand.addTarget(handler: { [weak self] (_) in
            self?.playNext()
            return MPRemoteCommandHandlerStatus.success
        })

        commandCenter.previousTrackCommand.addTarget(handler: { [weak self] (_) in
            self?.playPrevious()
            return MPRemoteCommandHandlerStatus.success
        })

        commandCenter.changePlaybackPositionCommand.addTarget(handler: { [weak self] (event) in

            guard let event = event as? MPChangePlaybackPositionCommandEvent
                else { return .noSuchContent }

            self?.seek(to: event.positionTime)
            return MPRemoteCommandHandlerStatus.success
        })
    }

}

extension KeepUpAudioPlayer {

    // MARK: Notification queue plauer

    fileprivate func configureReachability() {

        do {
            apReachability = try KPReachability()

            do {
                try apReachability?.start()
            } catch let error as Network.Error {
                print("Error. \(String(describing: type(of: self))) \(#function): \(error)")
            } catch {
                print("Error. \(String(describing: type(of: self))) \(#function): \(error)")
            }

        } catch {
            print("Error. \(String(describing: type(of: self))) \(#function): \(error)")
        }

        apReachability?.changed = { [weak self] connected in
            if connected == true {
                self?.queue.async {
                    self?.resumePlayIfNeeded()
                }
            }
        }
    }


    fileprivate func addQueuePlayerObservers() {

        queuePlayer.addObserver(self, forKeyPath: "status", options: [.initial, .new], context: nil)
        queuePlayer.addObserver(self, forKeyPath: "currentItem", options: [.initial, .new], context: nil)

        let interval = CMTime(value: 1, timescale: 1)
        timeObserverPlayer = queuePlayer.addPeriodicTimeObserver(forInterval: interval,
                                                                 queue: queue,
                                                                 using: { [weak self, weak queuePlayer] (time) in
                                                                    /** Возьмем данные item только со статусом readyToPlay.
                                                                     Потому что не в статусе readyToPlay без интернета
                                                                     очередь переходит к следующему треку и трек останавливается на 0 секунде,
                                                                     после подключения интернета начинает играть следующий трек */
                                                                    guard let _self = self, let item = queuePlayer?.currentItem, item.status == .readyToPlay else {
                                                                        return
                                                                    }

                                                                    if let itemUrl = item.url,
                                                                        let index = _self.items[itemUrl] {
                                                                        _self.state.currentIndex = index

                                                                        if _self.shuffleMode == .on {
                                                                            if _self.shufflePlayedIndexes.contains(index) == false {
                                                                                _self.shufflePlayedIndexes.append(index)
                                                                            }
                                                                        }
                                                                    }

                                                                    let assetTime = item.asset.duration

                                                                    if assetTime != kCMTimeIndefinite {
                                                                        _self.state.currentTime = Float64(time.value / Int64(time.timescale))
                                                                        _self.state.currentDuration = Float64(assetTime.value / Int64(assetTime.timescale))
                                                                    }

                                                                    _self.state.repeatMode = _self.repeatMode
                                                                    _self.state.shuffleMode = _self.shuffleMode

                                                                    _self.onPlayerState()
        })
    }

    fileprivate func removeQueuePlayerObservers() {
        if let observer = timeObserverPlayer {
            queuePlayer.removeTimeObserver(observer)
        }

        queuePlayer.removeObserver(self, forKeyPath: "status")
        queuePlayer.removeObserver(self, forKeyPath: "currentItem")
    }

    @objc fileprivate func appMovedFromBackground() {
        endBackgroundTask()

        self.queue.async {
            self.resumePlayIfNeeded()
        }
    }

    @objc fileprivate func appMovedInBackground() {
        startBackgroundTask()
    }
}

extension KeepUpAudioPlayer {

    // MARK: Notification plauer

    fileprivate func addPlayerObservers() {

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidPlayToEndTime),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemFailedToPlayToEndTime),
                                               name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemPlaybackStalled),
                                               name: NSNotification.Name.AVPlayerItemPlaybackStalled,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(audioSessionRouteChange),
                                               name: NSNotification.Name.AVAudioSessionRouteChange,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appMovedFromBackground),
                                               name: Notification.Name.UIApplicationDidBecomeActive,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appMovedInBackground),
                                               name: Notification.Name.UIApplicationWillResignActive,
                                               object: nil)
    }

    func removePlayerObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc fileprivate func playerItemDidPlayToEndTime(notif: NSNotification) {
        didPlayToEndTime()
        print("playerItemDidPlayToEndTime", notif.object ?? "")
    }

    @objc fileprivate func playerItemFailedToPlayToEndTime(notif: NSNotification) {
        didPlayToEndTime()
        print("playerItemFailedToPlayToEndTime", notif.object ?? "")
    }

    @objc fileprivate func playerItemPlaybackStalled(notif: NSNotification) {
        playbackStalled()
        print("playerItemPlaybackStalled", notif.object ?? "")
    }

    @objc fileprivate func audioSessionRouteChange(notif: NSNotification) {

        if let reason = notif.userInfo?["AVAudioSessionRouteChangeReasonKey"] as? Int {
            if reason == 1 {
                play()
            } else if reason == 2, state.needsPlaying == true {
                pause()
            }
        }
        print("audioSessionRouteChange", notif.object ?? "")
    }

//    func observe<Value>(_ keyPath: KeyPath<KeepUpAudioPlayer, Value>,
//                        options: NSKeyValueObservingOptions,
//                        changeHandler: @escaping (KeepUpAudioPlayer, NSKeyValueObservedChange<Value>) -> Void) -> NSKeyValueObservation {

//    }
    override internal func observeValue(forKeyPath keyPath: String?,
                                        of object: Any?,
                                        change: [NSKeyValueChangeKey: Any]?,
                                        context: UnsafeMutableRawPointer?) {

        guard let key = keyPath else {
            return
        }

        //print(key)
        let connected = self.apReachability?.isConnectedToNetwork

        queue.async {

            if key == "currentItem" {

                if let newPlayerItem = change?[.newKey] as? AVPlayerItem {
                    newPlayerItem.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
                    newPlayerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: [.new], context: nil)
                    newPlayerItem.addObserver(self, forKeyPath: "timedMetadata", options: [.new], context: nil)
                }

            } else if key == "loadedTimeRanges" {

                if let currentHash = self.queuePlayer.currentItem?.hash, currentHash != self.prepareingItemHash {
                    if connected == true {
                        self.prepareNextItem()
                        self.prepareingItemHash = currentHash
                    }
                }

            } else if key == "status" {

                if self.queuePlayer.status == .failed {
                    self.resumePlay()
                } else  if let item = object as? AVPlayerItem {
                    if item.status == .readyToPlay,
                        self.state.needsPlaying == true, self.queuePlayer.rate == 0 {
                        self.queuePlayer.play()
                    } else if item.status == .failed {
                        self.resumePlay()
                    }
                }

            } else if key == "timedMetadata" {

                if let item = object as? AVPlayerItem,
                    let metadata = item.timedMetadata, !metadata.isEmpty,
                    let value = metadata[0].value as? String {
                    self.state.timedMetadataValue = value
                } else {
                    self.state.timedMetadataValue = ""
                }
            }
        }
    }
}

extension KeepUpAudioPlayer {

    /** Если плеер не успел воспроизвести поток и свернули приложение, тогда приложение уйдет в фон и воспроизведения не будет.
        Если запустить startBackgroundTask(), воспроизведение начнется в фоновом режиме. */

    func startBackgroundTask() {
        DispatchQueue.global(qos: .default).async {
            self.backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {() -> Void in
                self.endBackgroundTask()
            })
        }
    }

    func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
}

fileprivate extension Dictionary where Key == URL, Value == Int {

    func url(at index: Int) -> URL? {

        let currentPair = first(where: { pair -> Bool in
            return pair.value == index
        })

        return currentPair?.key
    }
}
