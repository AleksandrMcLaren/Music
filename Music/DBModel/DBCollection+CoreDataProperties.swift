//
//  DBCollection+CoreDataProperties.swift
//  Music
//
//  Created by Aleksandr on 03.04.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//
//

import Foundation
import CoreData


extension DBCollection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBCollection> {
        return NSFetchRequest<DBCollection>(entityName: "DBCollection")
    }

    @NSManaged public var allTrackDuration: Int64
    @NSManaged public var cover_square: String?
    @NSManaged public var cover_wide: String?
    @NSManaged public var id: String?
    @NSManaged public var isUserLikes: Bool
    @NSManaged public var subtitle_en: String?
    @NSManaged public var subtitle_kk: String?
    @NSManaged public var subtitle_ru: String?
    @NSManaged public var title_en: String?
    @NSManaged public var title_kk: String?
    @NSManaged public var title_ru: String?
    @NSManaged public var trackCount: Int64
    @NSManaged public var collectionGroups: NSSet?
    @NSManaged public var peoples: NSOrderedSet?
    @NSManaged public var tracks: NSOrderedSet?

}

// MARK: Generated accessors for collectionGroups
extension DBCollection {

    @objc(addCollectionGroupsObject:)
    @NSManaged public func addToCollectionGroups(_ value: DBCollectionGroup)

    @objc(removeCollectionGroupsObject:)
    @NSManaged public func removeFromCollectionGroups(_ value: DBCollectionGroup)

    @objc(addCollectionGroups:)
    @NSManaged public func addToCollectionGroups(_ values: NSSet)

    @objc(removeCollectionGroups:)
    @NSManaged public func removeFromCollectionGroups(_ values: NSSet)

}

// MARK: Generated accessors for peoples
extension DBCollection {

    @objc(insertObject:inPeoplesAtIndex:)
    @NSManaged public func insertIntoPeoples(_ value: DBPeople, at idx: Int)

    @objc(removeObjectFromPeoplesAtIndex:)
    @NSManaged public func removeFromPeoples(at idx: Int)

    @objc(insertPeoples:atIndexes:)
    @NSManaged public func insertIntoPeoples(_ values: [DBPeople], at indexes: NSIndexSet)

    @objc(removePeoplesAtIndexes:)
    @NSManaged public func removeFromPeoples(at indexes: NSIndexSet)

    @objc(replaceObjectInPeoplesAtIndex:withObject:)
    @NSManaged public func replacePeoples(at idx: Int, with value: DBPeople)

    @objc(replacePeoplesAtIndexes:withPeoples:)
    @NSManaged public func replacePeoples(at indexes: NSIndexSet, with values: [DBPeople])

    @objc(addPeoplesObject:)
    @NSManaged public func addToPeoples(_ value: DBPeople)

    @objc(removePeoplesObject:)
    @NSManaged public func removeFromPeoples(_ value: DBPeople)

    @objc(addPeoples:)
    @NSManaged public func addToPeoples(_ values: NSOrderedSet)

    @objc(removePeoples:)
    @NSManaged public func removeFromPeoples(_ values: NSOrderedSet)

}

// MARK: Generated accessors for tracks
extension DBCollection {

    @objc(insertObject:inTracksAtIndex:)
    @NSManaged public func insertIntoTracks(_ value: DBTrack, at idx: Int)

    @objc(removeObjectFromTracksAtIndex:)
    @NSManaged public func removeFromTracks(at idx: Int)

    @objc(insertTracks:atIndexes:)
    @NSManaged public func insertIntoTracks(_ values: [DBTrack], at indexes: NSIndexSet)

    @objc(removeTracksAtIndexes:)
    @NSManaged public func removeFromTracks(at indexes: NSIndexSet)

    @objc(replaceObjectInTracksAtIndex:withObject:)
    @NSManaged public func replaceTracks(at idx: Int, with value: DBTrack)

    @objc(replaceTracksAtIndexes:withTracks:)
    @NSManaged public func replaceTracks(at indexes: NSIndexSet, with values: [DBTrack])

    @objc(addTracksObject:)
    @NSManaged public func addToTracks(_ value: DBTrack)

    @objc(removeTracksObject:)
    @NSManaged public func removeFromTracks(_ value: DBTrack)

    @objc(addTracks:)
    @NSManaged public func addToTracks(_ values: NSOrderedSet)

    @objc(removeTracks:)
    @NSManaged public func removeFromTracks(_ values: NSOrderedSet)

}
