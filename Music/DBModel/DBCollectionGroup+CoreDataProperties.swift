//
//  DBCollectionGroup+CoreDataProperties.swift
//  Music
//
//  Created by Aleksandr on 29.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//
//

import Foundation
import CoreData


extension DBCollectionGroup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBCollectionGroup> {
        return NSFetchRequest<DBCollectionGroup>(entityName: "DBCollectionGroup")
    }

    @NSManaged public var id: String?
    @NSManaged public var name_en: String?
    @NSManaged public var name_kk: String?
    @NSManaged public var name_ru: String?
    @NSManaged public var order: Int32
    @NSManaged public var type: String?
    @NSManaged public var collections: NSOrderedSet?

}

// MARK: Generated accessors for collections
extension DBCollectionGroup {

    @objc(insertObject:inCollectionsAtIndex:)
    @NSManaged public func insertIntoCollections(_ value: DBCollection, at idx: Int)

    @objc(removeObjectFromCollectionsAtIndex:)
    @NSManaged public func removeFromCollections(at idx: Int)

    @objc(insertCollections:atIndexes:)
    @NSManaged public func insertIntoCollections(_ values: [DBCollection], at indexes: NSIndexSet)

    @objc(removeCollectionsAtIndexes:)
    @NSManaged public func removeFromCollections(at indexes: NSIndexSet)

    @objc(replaceObjectInCollectionsAtIndex:withObject:)
    @NSManaged public func replaceCollections(at idx: Int, with value: DBCollection)

    @objc(replaceCollectionsAtIndexes:withCollections:)
    @NSManaged public func replaceCollections(at indexes: NSIndexSet, with values: [DBCollection])

    @objc(addCollectionsObject:)
    @NSManaged public func addToCollections(_ value: DBCollection)

    @objc(removeCollectionsObject:)
    @NSManaged public func removeFromCollections(_ value: DBCollection)

    @objc(addCollections:)
    @NSManaged public func addToCollections(_ values: NSOrderedSet)

    @objc(removeCollections:)
    @NSManaged public func removeFromCollections(_ values: NSOrderedSet)

}
