//
//  Collaction.swift
//  Music
//
//  Created by Aleksandr on 02.04.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation

class Collection {

    func getCard(_ ident: String, completion: ((DBCollection?, Bool) -> Swift.Void)?) {

        DispatchQueue.global(qos: .default).async {

            func asyncCompletion(_ obj: DBCollection?, _ changed: Bool) {
                DispatchQueue.main.async {
                    completion?(obj, changed)
                }
            }

            var params = [String: String]()
            params["method"] = "collaction.getCard"
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

extension Collection {

    func createCard(with json: [String: Any], completion: ((DBCollection?, _ changed: Bool) -> Swift.Void)?) {

        var album: DBCollection?
        var changed = false

        if let collectionDict = json["collection"] as? [String: Any],
            let albumIdentDict = collectionDict["collaction"] as? [String: Any], albumIdentDict.keys.count > 0,
            let albumKey = albumIdentDict.keys.first,
            let albumDict = albumIdentDict[albumKey] as? [String: Any] {

            /// album
            album = DBCollection.objectFromDict(albumDict)

            if let responceDict = json["response"] as? [String: Any],
                let trackIds = responceDict["tracks"] as? [Any],
                let tracksDict = collectionDict["track"] as? [String: Any] {

                let peoplesDict = collectionDict["people"] as? [String: Any]

                /// album => tracks
                album?.setTrackIds(trackIds)
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
              //  DataSource.shared.context.needsSave()
                changed = true
            }
        }

        completion?(album, changed)
    }
}

