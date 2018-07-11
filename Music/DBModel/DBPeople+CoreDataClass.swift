//
//  DBPeople+CoreDataClass.swift
//  Music
//
//  Created by Aleksandr on 29.01.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//
//

import Foundation
import CoreData

@objc(DBPeople)
public class DBPeople: NSManagedObject, ManagedObject, ObjectExistTracks {

    internal var trackIds: [String]?
    internal var categoryIds: [String]?

    static func objectFromDict(_ dict: [String: Any]) -> DBPeople? {
        var object: DBPeople?

        if let id = dict["id"] as? String {
            object = DBPeople.object(with: id) as? DBPeople
            object?.mapping(dict)
        }

        return object
    }

    func mapping(_ map: [String: Any]) {
        moc.performAndWait {
            id = map["id"] as? String
            name = map["name"] as? String
            cover = map["cover_file"] as? String
            isUserLikes = map.bool(by: "isUserLikes")

            categoryIds = map["categoryIds"] as? [String]
            trackIds = map["trackIds"] as? [String]
        }
    }
}

extension DBPeople {

    func addCategory(_ dict: [String: Any]) {
        guard let ids = categoryIds else {
            return
        }

        var genre_ru = [String]()
        var genre_en = [String]()
        var genre_kk = [String]()

        for id in ids {
            if let category = dict[id] as? [String: Any] {
                if let name = category["name"] as? String {
                    genre_ru.append(name)
                }
                if let name = category["en_name"] as? String {
                    genre_en.append(name)
                }
                if let name = category["kz_name"] as? String {
                    genre_kk.append(name)
                }
            }
        }

        moc.performAndWait {
            self.genre_ru = genre_ru.joined(separator: ", ")
            self.genre_en = genre_en.joined(separator: ", ")
            self.genre_kk = genre_kk.joined(separator: ", ")
        }
    }
}
