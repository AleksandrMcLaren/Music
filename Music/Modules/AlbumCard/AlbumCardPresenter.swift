//
//  AlbumCardPresenter.swift
//  Music
//
//  Created by Aleksandr on 07.02.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation

protocol AlbumCardPresentation: class {
    var object: AnyObject? { get set }
    var albumIdent: String? { get set }
    var collectionIdent: String? { get set }

    func fetch()
    func playTapped()
    func prevTapped()
    func nextTapped()
    func endTapped()
    func repeatTapped()
    func shuffleTapped()
    func downloadTapped()
}

class AlbumCardPresenter: AlbumCardPresentation {

    weak var view: AlbumCardViewPresentation?
    weak var headerView: AlbumCardHeaderPresentation?

    var object: AnyObject?
    var albumIdent: String?
    var collectionIdent: String?

    init() {
        addPlayContentNotifications()
    }

    deinit {
        removePlayContentNotifications()
    }

    // MARK: Configure
    func configureHeader() {

        if let obj = object as? DBAlbum {
            headerView?.cover = obj.cover
        } else if let obj = object as? DBCollection {
            headerView?.cover = obj.cover_square
        }

        let selected = player.playingContentObject(object)
        headerView?.buttonSelected = selected

        if let mode = player.playContent?.repeatMode {
            if mode == .once {
                headerView?.repeatText = "1"
            } else if mode == .on {
                headerView?.repeatText = "all"
            } else {
                headerView?.repeatText = ""
            }
        }

        if let mode = player.playContent?.shuffleMode {
            if mode == .off {
                headerView?.shuffleText = ""
            } else {
                headerView?.shuffleText = "On"
            }
        }
    }

    // MARK: Actions

    func playTapped() {

        let playingCurContent = player.playingContentObject(object)

        if playingCurContent == true {
            pause()
        } else {
            play()
        }
    }

    func play() {
        if let obj = object as? ObjectExistTracks, let track = obj[0] {
            player.playContent = PlayContent(with: obj, playTrack: track)
            player.play()
        }
    }

    func pause() {
       player.pause()
    }

    func prevTapped() {
        player.playPrevious()
    }

    func nextTapped() {
        player.playNext()
    }

    func endTapped() {
        if let dur = player.playContent?.currentDuration {
            let position = dur - 5
            player.seek(to: position)
        }
    }

    func repeatTapped() {
        player.setRepeatMode()
    }

    func shuffleTapped() {
        player.setShuffleMode()
    }

    func downloadTapped() {
        if let object = object as? ObjectDownload {
            object.download()
        }
    }

    // MARK: Interactor
    func fetch() {

        var tracksExist = false

        if let object = object as? ObjectExistTracks {
            configureHeader()

            if let obj = object as? DBAlbum {
                albumIdent = obj.id
            } else if let obj = object as? DBCollection {
                collectionIdent = obj.id
            }

            if let tracks = object.tracks?.array, !tracks.isEmpty {
                let source = createDataSource(with: object)
                view?.fetchCompletion(source)

                tracksExist = true
            }
        }

        if let ident = albumIdent {

            if tracksExist == false {
                view?.refreshing(true)
            }

            Album().getCard(ident) { [weak self] (album, changed) in
                self?.view?.refreshing(false)
                self?.fetchCompletion(with: album, changed)
            }

        } else if let ident = collectionIdent {

            if tracksExist == false {
                view?.refreshing(true)
            }

            Collection().getCard(ident) { [weak self] (collection, changed) in
                self?.view?.refreshing(false)
                self?.fetchCompletion(with: collection, changed)
            }
        }
    }

    func fetchCompletion(with object: AnyObject?, _ changed: Bool) {
        if let object = object as? ObjectExistTracks {
            if self.object == nil || changed == true {
                self.object = object
                configureHeader()

                let source = self.createDataSource(with: self.object)
                view?.fetchCompletion(source)
            }
        }
    }

    func createDataSource(with object: AnyObject?) -> TableDataSource? {
        var tableSource: TableDataSource?

        if let object = object as? ObjectExistTracks, let objects = object.tracks?.array {
            let section = TableDataSourceSection()

            if object is DBCollection {
                section.source = TrackSource().tracks(with: objects, parentObject: object)
            } else if object is DBAlbum {
                section.source = TrackNumberSource().tracks(with: objects, parentObject: object)
            }

            tableSource = TableDataSource()
            tableSource!.sections.append(section)
        }

        return tableSource
    }
}

extension AlbumCardPresenter: PlayContentNotification {

    func playContentChanged() {
        configureHeader()
    }
}
