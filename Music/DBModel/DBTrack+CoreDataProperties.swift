//
//  DBTrack+CoreDataProperties.swift
//  Music
//
//  Created by Aleksandr on 24.04.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//
//

import Foundation
import CoreData


extension DBTrack {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBTrack> {
        return NSFetchRequest<DBTrack>(entityName: "DBTrack")
    }

    @NSManaged public var cover: String?
    @NSManaged public var duration: Int64
    @NSManaged public var id: String?
    @NSManaged public var isUserLikes: Bool
    @NSManaged public var link: String?
    @NSManaged public var lyrics: String?
    @NSManaged public var name: String?
    @NSManaged public var peoplesList: String?
    @NSManaged public var album: DBAlbum?
    @NSManaged public var collections: NSSet?
    @NSManaged public var peoples: NSOrderedSet?
    @NSManaged public var recommendationGroup: NSSet?

}

// MARK: Generated accessors for collections
extension DBTrack {

    @objc(addCollectionsObject:)
    @NSManaged public func addToCollections(_ value: DBCollection)

    @objc(removeCollectionsObject:)
    @NSManaged public func removeFromCollections(_ value: DBCollection)

    @objc(addCollections:)
    @NSManaged public func addToCollections(_ values: NSSet)

    @objc(removeCollections:)
    @NSManaged public func removeFromCollections(_ values: NSSet)

}

// MARK: Generated accessors for peoples
extension DBTrack {

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

// MARK: Generated accessors for recommendationGroup
extension DBTrack {

    @objc(addRecommendationGroupObject:)
    @NSManaged public func addToRecommendationGroup(_ value: DBRecommendationGroup)

    @objc(removeRecommendationGroupObject:)
    @NSManaged public func removeFromRecommendationGroup(_ value: DBRecommendationGroup)

    @objc(addRecommendationGroup:)
    @NSManaged public func addToRecommendationGroup(_ values: NSSet)

    @objc(removeRecommendationGroup:)
    @NSManaged public func removeFromRecommendationGroup(_ values: NSSet)

}
