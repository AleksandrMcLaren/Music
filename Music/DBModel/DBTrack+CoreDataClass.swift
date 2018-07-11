//
//  DBTrack+CoreDataClass.swift
//  Music
//
//  Created by Aleksandr on 29.01.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//
//

import Foundation
import CoreData

@objc(DBTrack)
public class DBTrack: NSManagedObject, ManagedObject, ManagedObjectAddPeople, ManagedObjectAddPeopleList {

    var peopleIds: [String]?
    var parentId: String?

    static func objectFromDict(_ dict: [String: Any]) -> DBTrack? {
        var object: DBTrack?

        if let id = dict["id"] as? String {
            object = DBTrack.object(with: id) as? DBTrack
            object?.mapping(dict)
        }

        return object
    }

    func mapping(_ map: [String: Any]) {
        moc.performAndWait {
            id = map["id"] as? String
            name = map["name"] as? String
            cover = map["cover"] as? String
            duration = map.int64(by: "duration")
            isUserLikes = map.bool(by: "isUserLikes")

            peopleIds = map["peopleIds"] as? [String]
            parentId = map["parent"] as? String
        }
    }

    func setLink(_ link: String) {
        moc.performAndWait {
            self.link = link
        }
    }

    func addAlbum(with dict: [String: Any]?) {
        guard let id = parentId, let dict = dict else {
            return
        }

        if let albumDict = dict[id] as? [String: Any],
            let album = DBAlbum.objectFromDict(albumDict) {
            moc.performAndWait {
                self.album = album
            }
        }
    }

    // MARK: View Model Fields

    func timeString() -> String {
        let min = duration / 60
        let sec = duration % 60
        let time = "\(min)" + String(format: ":%.2d", sec)
        return time
    }
}

extension DBTrack {

    func download() {
        DownloadManager.shared.downloadTrack(self)
    }
}
