//
//  DBRecommendationGroup+CoreDataProperties.swift
//  Music
//
//  Created by Aleksandr on 27.04.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//
//

import Foundation
import CoreData


extension DBRecommendationGroup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBRecommendationGroup> {
        return NSFetchRequest<DBRecommendationGroup>(entityName: "DBRecommendationGroup")
    }

    @NSManaged public var id: String?
    @NSManaged public var order: Int32
    @NSManaged public var slug: String?
    @NSManaged public var subtitle_en: String?
    @NSManaged public var subtitle_kk: String?
    @NSManaged public var subtitle_ru: String?
    @NSManaged public var title_en: String?
    @NSManaged public var title_kk: String?
    @NSManaged public var title_ru: String?
    @NSManaged public var categoryId: String?
    @NSManaged public var albums: NSOrderedSet?
    @NSManaged public var peoples: NSOrderedSet?
    @NSManaged public var tracks: NSOrderedSet?

}

// MARK: Generated accessors for albums
extension DBRecommendationGroup {

    @objc(insertObject:inAlbumsAtIndex:)
    @NSManaged public func insertIntoAlbums(_ value: DBAlbum, at idx: Int)

    @objc(removeObjectFromAlbumsAtIndex:)
    @NSManaged public func removeFromAlbums(at idx: Int)

    @objc(insertAlbums:atIndexes:)
    @NSManaged public func insertIntoAlbums(_ values: [DBAlbum], at indexes: NSIndexSet)

    @objc(removeAlbumsAtIndexes:)
    @NSManaged public func removeFromAlbums(at indexes: NSIndexSet)

    @objc(replaceObjectInAlbumsAtIndex:withObject:)
    @NSManaged public func replaceAlbums(at idx: Int, with value: DBAlbum)

    @objc(replaceAlbumsAtIndexes:withAlbums:)
    @NSManaged public func replaceAlbums(at indexes: NSIndexSet, with values: [DBAlbum])

    @objc(addAlbumsObject:)
    @NSManaged public func addToAlbums(_ value: DBAlbum)

    @objc(removeAlbumsObject:)
    @NSManaged public func removeFromAlbums(_ value: DBAlbum)

    @objc(addAlbums:)
    @NSManaged public func addToAlbums(_ values: NSOrderedSet)

    @objc(removeAlbums:)
    @NSManaged public func removeFromAlbums(_ values: NSOrderedSet)

}

// MARK: Generated accessors for peoples
extension DBRecommendationGroup {

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
extension DBRecommendationGroup {

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
