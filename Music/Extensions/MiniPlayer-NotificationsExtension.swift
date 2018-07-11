//
//  MiniPlayer-NotificationsExtension.swift
//  Music
//
//  Created by Aleksandr on 07.02.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation

let MiniPlayerNeedsOpenNotificationName = NSNotification.Name("MiniPlayerNeedsOpenName")
let MiniPlayerLayoutNotificationName = NSNotification.Name("MiniPlayerLayoutName")

@objc protocol MiniPlayerNotification {
    func miniPlayerLayout()
    @objc optional func miniPlayerNeedsOpen()
}

extension MiniPlayerNotification {

    // MARK: Layout
    func addMiniPlayerLayoutNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(miniPlayerLayout),
                                               name: MiniPlayerLayoutNotificationName,
                                               object: nil)
    }

    func removeMiniPlayerLayoutNotification() {
        NotificationCenter.default.removeObserver(self,
                                                  name: MiniPlayerLayoutNotificationName,
                                                  object: nil)
    }

    // MARK: Needs open
    func addMiniPlayerNeedsOpenNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(miniPlayerNeedsOpen),
                                               name: MiniPlayerNeedsOpenNotificationName,
                                               object: nil)
    }

    func removeMiniPlayerNeedsOpenNotification() {
        NotificationCenter.default.removeObserver(self,
                                                  name: MiniPlayerNeedsOpenNotificationName,
                                                  object: nil)
    }
}
