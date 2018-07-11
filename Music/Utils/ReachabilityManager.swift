//
//  ReachabilityManager.swift
//  Music
//
//  Created by Aleksandr on 02.02.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit
import ReachabilitySwift

class ReachabilityManager {

    fileprivate let reachability = Reachability()

    var isNetworkAvailable: Bool {
        return reachability?.currentReachabilityStatus != .notReachable
    }

    static let shared = ReachabilityManager()
    fileprivate init() {}

    func startNotifier() {
        try? reachability?.startNotifier()
    }
}
