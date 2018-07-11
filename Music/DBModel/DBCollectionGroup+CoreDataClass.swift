//
//  DBCollectionGroup+CoreDataClass.swift
//  Music
//
//  Created by Aleksandr on 29.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//
//

import Foundation
import CoreData

@objc(DBCollectionGroup)
public class DBCollectionGroup: NSManagedObject, ManagedObject, ManagedObjectAddCollection {

    var collectionIds: [String]?
    var trackCount: [String: Int64]?
    var allTrackDuration: [String: Int64]?

    static func objectFromDict(_ dict: [String: Any]) -> DBCollectionGroup? {
        var object: DBCollectionGroup?

        if let id = dict["id"] as? String {
            object = DBCollectionGroup.object(with: id) as? DBCollectionGroup
            object?.mapping(dict)
        }

        return object
    }

    func mapping(_ map: [String: Any]) {
        moc.performAndWait {
            id = map["id"] as? String
            type = map["TemplateType"] as? String

            if let names = map["names"] as? [String: Any] {
                name_en = names["en"] as? String
                name_ru = names["ru"] as? String
                name_kk = names["kk"] as? String
            }

            collectionIds = map["selectionIds"] as? [String]
            trackCount = map["trackCount"] as? [String: Int64]
            allTrackDuration = map["allTrackDuration"] as? [String: Int64]
        }
    }

    func setOrder(_ order: Int32) {
        moc.performAndWait {
            self.order = order
        }
    }

    func addTrackDataCollections() {
        guard let collections = collections else {
            return
        }

        for cl in collections.array {
            if let cl = cl as? DBCollection, let id = cl.id {
                if let trackCount = trackCount {
                    cl.trackCount = trackCount[id] ?? 0
                }

                if let allTrackDuration = allTrackDuration {
                    cl.allTrackDuration = allTrackDuration[id] ?? 0
                }
            }
        }
    }

    // MARK: View Model Fields

    var name: String? {
        return name_en
    }
}
