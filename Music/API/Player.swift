//
//  Player.swift
//  Music
//
//  Created by Aleksandr on 01.02.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation

class Player {

    deinit {

    }

    func getStreamingLink(_ track: DBTrack, completion: ((_ changed: Bool) -> Swift.Void)?) {
        DispatchQueue.global(qos: .default).async {

            func asyncCompletion(_ changed: Bool) {
                DispatchQueue.main.async {
                    completion?(changed)
                }
            }

            var params = [String: String]()
            params["method"] = "player.getStreamingLink"
            params["trackId"] = track.id
            params["quality"] = "1"

            API.shared.get(params) { (json) in
                guard let json = json else {
                    asyncCompletion(false)
                    return
                }

                self.createStreamingLink(with: json, track, completion: { (changed) in
                    asyncCompletion(changed)
                })
            }
        }
    }
}

extension Player {

    func createStreamingLink(with json: [String: Any], _ track: DBTrack, completion: ((_ changed: Bool) -> Swift.Void)?) {

        var changed = false

        if let responceDict = json["response"] as? [String: Any],
            let link = responceDict["link"] as? String {
            track.setLink(link)
        }

        if track.changed() == true {
            DataSource.shared.context.needsSave()
            changed = true
        }

        completion?(changed)
    }
}
