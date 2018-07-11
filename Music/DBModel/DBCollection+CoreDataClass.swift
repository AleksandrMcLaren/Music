//
//  DBCollection+CoreDataClass.swift
//  Music
//
//  Created by Aleksandr on 29.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//
//

import Foundation
import CoreData

@objc(DBCollection)
public class DBCollection: NSManagedObject, ManagedObject, ObjectExistTracks, ObjectDownload {

    internal var trackIds: [String]?

    static func objectFromDict(_ dict: [String: Any]) -> DBCollection? {
        var object: DBCollection?

        if let id = dict["id"] as? String {
            object = DBCollection.object(with: id) as? DBCollection
            object?.mapping(dict)
        }

        return object
    }

    func mapping(_ map: [String: Any]) {
        moc.performAndWait {
            id = map["id"] as? String
            title_en = map["title"] as? String
            title_ru = map["en_title"] as? String
            title_kk = map["kz_title"] as? String
            subtitle_en = map["subtitle"] as? String
            subtitle_ru = map["en_subtitle"] as? String
            subtitle_kk = map["kz_subtitle"] as? String
            cover_square = map["selectionImages_square"] as? String
            cover_wide = map["selectionImages_wide"] as? String
            isUserLikes = map.bool(by: "isUserLikes")
            /// не во всех методах приходят поля вложенные в словарь подборки
            allTrackDuration = map.int64(by: "allTrackDuration")
            trackCount = map.int64(by: "trackCount")
        }
    }

    func setTrackDuration(_ dur: Int64) {
        moc.performAndWait {
            allTrackDuration = dur
        }
    }

    func setTrackCount(_ count: Int64) {
        moc.performAndWait {
            trackCount = count
        }
    }
}
