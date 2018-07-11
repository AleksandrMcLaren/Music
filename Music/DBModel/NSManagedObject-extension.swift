//
//  NSManagedObject-extension.swift
//  Music
//
//  Created by Aleksandr on 29.01.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {

    /// Возвращает true если поля NSManagedObject были изменены
    func changed() -> Bool {
        return hasPersistentChangedValues
    }
}

/// Методы работы с БД
protocol ManagedObject {
    /// Создает объект c id
    static func object(with id: String) -> NSManagedObject?
    static func existObject(with id: String) -> NSManagedObject?
    static func getAll() -> [NSManagedObject]?
    static func deleteObjects(_ objects: [NSManagedObject])
}

extension ManagedObject {

    static func object(with id: String) -> NSManagedObject? {
        
        var object: NSManagedObject?

        moc.performAndWait {
            
            do {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: self))
                request.predicate = NSPredicate(format: "id == %@", id)
                request.fetchLimit = 1
                request.returnsObjectsAsFaults = false
                object = try moc.fetch(request).first as? NSManagedObject

                if object == nil {
                    object = NSEntityDescription.insertNewObject(forEntityName: String(describing: self), into: moc)
                    print("object insert ", id)
                }
            } catch {
                print("------ !!!")
                print("Error. \(String(describing: type(of: self))) \(#function): \(error)")
            }
        }

        return object
    }

    static func existObject(with id: String) -> NSManagedObject? {

        var object: NSManagedObject?

        moc.performAndWait {
            do {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: self))
                request.predicate = NSPredicate(format: "id == %@", id)
                request.fetchLimit = 1
                object = try moc.fetch(request).first as? NSManagedObject
            } catch {
                print("Error. \(String(describing: type(of: self))) \(#function): \(error)")
            }
        }

        return object
    }

    static func getAll() -> [NSManagedObject]? {
        var object: [NSManagedObject]?

        moc.performAndWait {
            do {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: self))
                request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: false)]
                object = try moc.fetch(request) as? [NSManagedObject]
            } catch {
                print("Error. \(String(describing: type(of: self))) \(#function): \(error)")
            }
        }

        return object
    }

    static func deleteObjects(_ objects: [NSManagedObject]) {
        moc.performAndWait {
            for object in objects {
                moc.delete(object)
            }
        }
    }
}

/// Добавляет OrderedSet исполнителей
protocol ManagedObjectAddPeople {
    var peopleIds: [String]? { get set }
    var peoples: NSOrderedSet? { get set }
    func addToPeoples(_ values: NSOrderedSet)
    func removeFromPeoples(_ values: NSOrderedSet)
}

extension ManagedObjectAddPeople {

    func addPeoples(_ dict: [String: Any]?) {

        guard let ids = peopleIds, let dict = dict else {
            return
        }

        let newObjects = NSMutableOrderedSet()

        for id in ids {
            if let objectDict = dict[id] as? [String: Any] {
                if let obj = DBPeople.objectFromDict(objectDict) {
                    newObjects.add(obj)
                }
            }
        }

        moc.performAndWait {

            if let objects = peoples {

                if objects.isEqual(to: newObjects) {
                    return
                }

                removeFromPeoples(objects)
            }

            if newObjects.count > 0 {
                addToPeoples(newObjects)
            }
        }
    }
}

/// Создает peoplesList
protocol ManagedObjectAddPeopleList: AnyObject {
    var peoples: NSOrderedSet? { get set }
    var peoplesList: String? { get set }
}

extension ManagedObjectAddPeopleList {

    func createPeopleList() {
        guard let peoples = peoples?.array else {
            return
        }

        var names = [String]()

        for people in peoples {
            if let p = people as? DBPeople,
                let name = p.name, name.count > 0 {
                names.append(name)
            }
        }

        if names.count > 0 {
            let ss = names.joined(separator: ", ")
            moc.performAndWait {
                peoplesList = ss
            }
        }
    }
}

/// Добавляет OrderedSet треков
protocol ObjectExistTracks: AnyObject {
    var id: String? { get set }
    var trackIds: [String]? { get set }
    var tracks: NSOrderedSet? { get set }

    subscript(index: Int) -> DBTrack? { get }

    func setTrackIds(_ ids: [Any])
    func addToTracks(_ values: NSOrderedSet)
    func removeFromTracks(_ values: NSOrderedSet)
}

extension ObjectExistTracks {

    func addTracks(_ dict: [String: Any]?) {

        guard let ids = trackIds, let dict = dict else {
            return
        }

        let newObjects = NSMutableOrderedSet()

        for id in ids {
            if let objectDict = dict[id] as? [String: Any] {
                if let obj = DBTrack.objectFromDict(objectDict) {
                    newObjects.add(obj)
                }
            }
        }

        moc.performAndWait {

            if let objects = tracks {

                if objects.isEqual(to: newObjects) {
                    return
                }

                removeFromTracks(objects)
            }

            if newObjects.count > 0 {
                addToTracks(newObjects)
            }
        }
    }

    subscript(index: Int) -> DBTrack? {

        if let tracks = tracks?.array,
            index < tracks.count {
            return tracks[index] as? DBTrack
        }

        return nil
    }

    func setTrackIds(_ ids: [Any]) {
        /// для треков с бакенда приходят ids с типом Int
        /// приведем к String
        if !ids.isEmpty {
            let firstId = ids.first

            if firstId is String {
                trackIds = ids as? [String]
            } else if firstId is Int {
                trackIds = ids.map {String(describing: $0)}
            }
        }
    }
}

/// Добавляет OrderedSet подборок
protocol ManagedObjectAddCollection: AnyObject {
    var collectionIds: [String]? { get set }
    var collections: NSOrderedSet? { get set }
    func addToCollections(_ values: NSOrderedSet)
    func removeFromCollections(_ values: NSOrderedSet)
    func setCollectionIds(_ ids: [Any])
}

extension ManagedObjectAddCollection {

    func addCollections(_ dict: [String: Any]) {

        guard let ids = collectionIds else {
            return
        }

        let newObjects = NSMutableOrderedSet()

        for id in ids {
            if let objectDict = dict[id] as? [String: Any] {
                if let obj = DBCollection.objectFromDict(objectDict) {
                    newObjects.add(obj)
                }
            }
        }

        moc.performAndWait {

            if let objects = collections {

                if objects.isEqual(to: newObjects) {
                    return
                }

                removeFromCollections(objects)
            }

            if newObjects.count > 0 {
                addToCollections(newObjects)
            }
        }
    }

    func setCollectionIds(_ ids: [Any]) {
        /// c бакенда приходят ids с типом Int
        /// приведем к String
        if !ids.isEmpty {
            let firstId = ids.first

            if firstId is String {
                collectionIds = ids as? [String]
            } else if firstId is Int {
                collectionIds = ids.map {String(describing: $0)}
            }
        }
    }
}

/// Добавляет OrderedSet альбомов
protocol ManagedObjectAddAlbum: AnyObject {
    var albumIds: [String]? { get set }
    var albums: NSOrderedSet? { get set }
    func addToAlbums(_ values: NSOrderedSet)
    func removeFromAlbums(_ values: NSOrderedSet)
    func setAlbumIds(_ ids: [Any])
}

extension ManagedObjectAddAlbum {

    func addAlbums(_ dict: [String: Any]?) {

        guard let ids = albumIds, let dict = dict else {
            return
        }

        let newObjects = NSMutableOrderedSet()

        for id in ids {
            if let objectDict = dict[id] as? [String: Any] {
                if let obj = DBAlbum.objectFromDict(objectDict) {
                    newObjects.add(obj)
                }
            }
        }

        moc.performAndWait {

            if let objects = albums {

                if objects.isEqual(to: newObjects) {
                    return
                }

                removeFromAlbums(objects)
            }

            if newObjects.count > 0 {
                addToAlbums(newObjects)
            }
        }
    }

    func setAlbumIds(_ ids: [Any]) {
        /// c бакенда приходят ids с типом Int
        /// приведем к String
        if !ids.isEmpty {
            let firstId = ids.first

            if firstId is String {
                albumIds = ids as? [String]
            } else if firstId is Int {
                albumIds = ids.map {String(describing: $0)}
            }
        }
    }
}

/// Загрузка
protocol ObjectDownload: ObjectExistTracks {
    func download()
}

extension ObjectDownload {

    func download() {
        DownloadManager.shared.downloadObject(self)
    }
}

