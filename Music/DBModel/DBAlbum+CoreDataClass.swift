//
//  DBAlbum+CoreDataClass.swift
//  Music
//
//  Created by Aleksandr on 29.01.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//
//

import Foundation
import CoreData

@objc(DBAlbum)
public class DBAlbum: NSManagedObject, ManagedObject, ManagedObjectAddPeople, ManagedObjectAddPeopleList, ObjectExistTracks, ObjectDownload {

    internal var trackIds: [String]?
    internal var peopleIds: [String]?

    static func objectFromDict(_ dict: [String: Any]) -> DBAlbum? {
        var object: DBAlbum?

        if let id = dict["id"] as? String {
            object = DBAlbum.object(with: id) as? DBAlbum
            object?.mapping(dict)
        }

        return object
    }

    fileprivate func mapping(_ map: [String: Any]) {
        DataSource.shared.context.performAndWait {
            setValue(map["id"] as? String, forKey: "id")
            setValue(map["name"] as? String, forKey: "name")
            setValue(map["cover"] as? String, forKey: "cover")
            setValue(map["isUserLikes"] as? Int, forKey: "isUserLikes")
            setValue(map["duration"] as? Int, forKey: "duration")
        }

        peopleIds = map["peopleIds"] as? [String]
        trackIds = map["trackIds"] as? [String]
    }

    // MARK: View Model Fields

    func timeString() -> String {
        let min = duration / 60
        let sec = duration % 60
        let time = "\(min)" + String(format: ":%.2d", sec)
        return time
    }
}
