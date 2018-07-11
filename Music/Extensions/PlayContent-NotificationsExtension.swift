//
//  PlayContentChanged-ObserverProtocol.swift
//  Music
//
//  Created by Aleksandr on 07.02.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation

@objc protocol PlayContentNotification {
    func playContentChanged()
}

extension PlayContentNotification {

    func addPlayContentNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playContentChanged),
                                               name: PlayContent.changed,
                                               object: nil)
    }

    func removePlayContentNotifications() {
        NotificationCenter.default.removeObserver(self,
                                                  name: PlayContent.changed,
                                                  object: nil)
    }
}
