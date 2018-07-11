//
//  Album.swift
//  Music
//
//  Created by Aleksandr on 23.01.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation

class Album {

    func getCard(_ ident: String, completion: ((DBAlbum?, Bool) -> Swift.Void)?) {

        DispatchQueue.global(qos: .default).async {

            func asyncCompletion(_ obj: DBAlbum?, _ changed: Bool) {
                DispatchQueue.main.async {
                    completion?(obj, changed)
                }
            }

            var params = [String: String]()
            params["method"] = "product.getCard"
            params["productId"] = ident

            API.shared.get(params) { (json) in
                guard let json = json else {
                    asyncCompletion(nil, false)
                    return
                }

                self.createCard(with: json, completion: { (object, changed) in
                    asyncCompletion(object, changed)
                })
            }
        }
    }
}

extension Album {

    func createCard(with json: [String: Any], completion: ((DBAlbum?, _ changed: Bool) -> Swift.Void)?) {

        var album: DBAlbum?
        var changed = false

        if let collectionDict = json["collection"] as? [String: Any],
            let albumIdentDict = collectionDict["album"] as? [String: Any],
                albumIdentDict.keys.count > 0,
            let albumKey = albumIdentDict.keys.first,
            let albumDict = albumIdentDict[albumKey] as? [String: Any] {

            /// album
            album = DBAlbum.objectFromDict(albumDict)

            /// album => peoples
            let peoplesDict = collectionDict["people"] as? [String: Any]
            album?.addPeoples(peoplesDict)

            if let responceDict = json["response"] as? [String: Any],
                let productChildIds = responceDict["productChildIds"] as? [Any],
                let tracksDict = collectionDict["track"] as? [String: Any] {
                /// album => tracks
                album?.setTrackIds(productChildIds)
                album?.addTracks(tracksDict)

                /// album => tracks => peoples
                if let tracks = album?.tracks?.array as? [DBTrack] {
                    for track in tracks {
                        track.addPeoples(peoplesDict)
                        track.createPeopleList()
                    }
                }
            }

            if album?.changed() == true {
               // DataSource.shared.context.needsSave()
                changed = true
            }
        }

        completion?(album, changed)
    }
}
