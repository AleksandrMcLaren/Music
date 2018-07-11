//
//  DBRecommendationGroup+CoreDataClass.swift
//  Music
//
//  Created by Aleksandr on 23.04.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//
//

import Foundation
import CoreData

@objc(DBRecommendationGroup)
public class DBRecommendationGroup: NSManagedObject, ManagedObject, ObjectExistTracks, ManagedObjectAddPeople, ManagedObjectAddAlbum {

    internal var trackIds: [String]?
    internal var peopleIds: [String]?
    internal var albumIds: [String]?

    static func objectFromDict(_ dict: [String: Any]) -> DBRecommendationGroup? {
        var object: DBRecommendationGroup?

        if let id = dict["id"] as? Int {
            let stringId = String(id)
            object = DBRecommendationGroup.object(with: stringId) as? DBRecommendationGroup
            object?.mapping(dict)
        }

        return object
    }

    func mapping(_ map: [String: Any]) {
        moc.performAndWait {
            if let ident = map["id"] as? Int {
                id = String(ident)
            }
            title_en = map["title"] as? String
            title_ru = map["en_title"] as? String
            title_kk = map["kz_title"] as? String
            subtitle_en = map["subtitle"] as? String
            subtitle_ru = map["en_subtitle"] as? String
            subtitle_kk = map["kz_subtitle"] as? String
            slug = map["slug"] as? String

            peopleIds = map["peopleIds"] as? [String]
        }
    }

    func setOrder(_ order: Int32) {
        moc.performAndWait {
            self.order = order
        }
    }

    // MARK: View Model Fields

    var title: String? {
        return title_en
    }
}
