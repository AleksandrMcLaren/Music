//
//  DownloadManager.swift
//  Music
//
//  Created by Aleksandr on 12.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation
import CoreData

protocol DownloadManagerPresentable: class {
    static var shared: DownloadManagerPresentable { get }
    /// Треки
    func downloadTrack(_ track: DBTrack)
    func existLocalTrack(_ track: DBTrack) -> Bool
    /// Загружает треки объектов протокола ObjectExistTracks.
    /// Альбом, Подборка
    func downloadObject(_ object: ObjectExistTracks)
}

class DownloadManager: DownloadManagerPresentable {

    static let shared: DownloadManagerPresentable = DownloadManager()
    fileprivate init() {}

    fileprivate var trackDownloaders = [String: FileDownloaderPresentable]()
    fileprivate let downloaders = Downloaders()

    fileprivate lazy var filesDirectory: String = {
        let fileManager = FileManager.default
        let path = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var filesDirectory = path.appendingPathComponent("music_resources")
        var isDir: ObjCBool = false

        if fileManager.fileExists(atPath: filesDirectory.path) == false {
            do {
                try fileManager.createDirectory(atPath: filesDirectory.path, withIntermediateDirectories: true, attributes: nil)

                if fileManager.fileExists(atPath: filesDirectory.path) {
                    var resourceValues = URLResourceValues()
                    resourceValues.isExcludedFromBackup = true
                    try filesDirectory.setResourceValues(resourceValues)
                }
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }

        return filesDirectory.path
    }()

    // MARK: DownloadManagerPresentable

    func downloadTrack(_ track: DBTrack) {

        guard let ident = track.id else {
            return
        }

        if let downloader = trackDownloaders[ident] {
            downloader.cancel()
            return
        }

        let downloader: FileDownloaderPresentable = FileDownloader()
        downloader.completion = { [unowned self] (success) in
            self.trackDownloaders.removeValue(forKey: ident)
            print("track downloader.completion")
        }

        trackDownloaders[ident] = downloader

        let queue = DispatchQueue(label: "com.downloadManager.downloadTrack")
        queue.async {
            self.getLinkTracks([track]) { [unowned self] in
                if let link = track.link {
                    if let downloader = self.trackDownloaders[ident] {
                        let data = self.createData(with: link, destinationPath: self.filePath(with: ident))

                        DispatchQueue.main.async {
                            downloader.download(data)
                        }
                    }
                }
            }
        }
    }

    func downloadObject(_ object: ObjectExistTracks) {

        guard let tracks = object.tracks?.array as? [DBTrack], tracks.count > 0 else {
            return
        }

        if let downloader = downloaders.get(object) {
            /// По второму вызову закроем загрузку
            downloader.cancel()
            return
        }

        downloaders.addObject(object)

        if let downloader = downloaders.get(object) {
            downloader.completion = { [unowned self] (success) in
                self.downloaders.remove(object)
                print("album downloader.completion \(success)")
            }
        }

        let queue = DispatchQueue(label: "com.downloadManager.downloadAlbum")
        queue.async {
            self.getLinkTracks(tracks) { [unowned self] in
                var dataList = [FileData]()

                for track in tracks {
                    if let ident = track.id, 
                        let link = track.link {
                        let data = self.createData(with: link, destinationPath: self.filePath(with: ident))
                        dataList.append(data)
                    }
                }

                DispatchQueue.main.async {
                    if let downloader = self.downloaders.get(object) {
                        downloader.download(dataList)
                    }
                }
            }
        }
    }

    func existLocalTrack(_ track: DBTrack) -> Bool {
        return FileManager.default.fileExists(atPath: filePath(with: track.id ?? ""))
    }

    fileprivate func createData(with link: String, destinationPath: String) -> FileData {
        let data = FileData(with: link, to: destinationPath)

        data.progress = { progress in
            print(progress)
        }

        data.completion = { success in
            print("data.completion \(success)")
        }

        return data
    }

    /// Необходимо вызывать в асинхронном потоке
    fileprivate func getLinkTracks(_ tracks: [DBTrack], completion: (() -> Swift.Void)?) {

        for track in tracks {
            if track.link == nil {
                let semaphore = DispatchSemaphore(value: 0)

                Player().getStreamingLink(track) { (changed) in
                    semaphore.signal()
                }
                semaphore.wait()
            }
        }

        completion?()
    }

    fileprivate func filePath(with ident: String) -> String {
        return filesDirectory + "/track_\(ident).mp3"
    }
}

class Downloaders {

    fileprivate var albumDownloaders = [String: FileDownloaderPresentable]()
    fileprivate var collectionDownloaders = [String: FileDownloaderPresentable]()

    fileprivate func addObject(_ obj: ObjectExistTracks) {
        if let ident = obj.id {
            if obj is DBAlbum {
                return albumDownloaders[ident] = FileDownloader()
            } else if obj is DBCollection {
                return collectionDownloaders[ident] = FileDownloader()
            }
        }
    }

    fileprivate func get(_ obj: ObjectExistTracks) -> FileDownloaderPresentable? {

        if let ident = obj.id {
            if obj is DBAlbum {
                return albumDownloaders[ident]
            } else if obj is DBCollection {
                return collectionDownloaders[ident]
            }
        }

        return nil
    }

    fileprivate func remove(_ obj: ObjectExistTracks) {
        if let ident = obj.id {
            if obj is DBAlbum {
                albumDownloaders.removeValue(forKey: ident)
            } else if obj is DBCollection {
                collectionDownloaders.removeValue(forKey: ident)
            }
        }
    }
}
