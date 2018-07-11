//
//  DBPeople+CoreDataProperties.swift
//  Music
//
//  Created by Aleksandr on 24.04.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//
//

import Foundation
import CoreData


extension DBPeople {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBPeople> {
        return NSFetchRequest<DBPeople>(entityName: "DBPeople")
    }

    @NSManaged public var cover: String?
    @NSManaged public var id: String?
    @NSManaged public var isUserLikes: Bool
    @NSManaged public var name: String?
    @NSManaged public var genre_en: String?
    @NSManaged public var genre_ru: String?
    @NSManaged public var genre_kk: String?
    @NSManaged public var albums: NSSet?
    @NSManaged public var collection: NSSet?
    @NSManaged public var tracks: NSOrderedSet?
    @NSManaged public var recommendationGroup: NSSet?

}

// MARK: Generated accessors for albums
extension DBPeople {

    @objc(addAlbumsObject:)
    @NSManaged public func addToAlbums(_ value: DBAlbum)

    @objc(removeAlbumsObject:)
    @NSManaged public func removeFromAlbums(_ value: DBAlbum)

    @objc(addAlbums:)
    @NSManaged public func addToAlbums(_ values: NSSet)

    @objc(removeAlbums:)
    @NSManaged public func removeFromAlbums(_ values: NSSet)

}

// MARK: Generated accessors for collection
extension DBPeople {

    @objc(addCollectionObject:)
    @NSManaged public func addToCollection(_ value: DBCollection)

    @objc(removeCollectionObject:)
    @NSManaged public func removeFromCollection(_ value: DBCollection)

    @objc(addCollection:)
    @NSManaged public func addToCollection(_ values: NSSet)

    @objc(removeCollection:)
    @NSManaged public func removeFromCollection(_ values: NSSet)

}

// MARK: Generated accessors for tracks
extension DBPeople {

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

// MARK: Generated accessors for recommendationGroup
extension DBPeople {

    @objc(addRecommendationGroupObject:)
    @NSManaged public func addToRecommendationGroup(_ value: DBRecommendationGroup)

    @objc(removeRecommendationGroupObject:)
    @NSManaged public func removeFromRecommendationGroup(_ value: DBRecommendationGroup)

    @objc(addRecommendationGroup:)
    @NSManaged public func addToRecommendationGroup(_ values: NSSet)

    @objc(removeRecommendationGroup:)
    @NSManaged public func removeFromRecommendationGroup(_ values: NSSet)

}
