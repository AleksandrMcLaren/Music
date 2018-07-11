//
//  DownloaderSessions.swift
//  Music
//
//  Created by Aleksandr on 15.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation

class DownloaderSessions {

    static let shared = DownloaderSessions()
    private init() {}

    fileprivate var urlSession = [URLSession: String]()

    func setUrl(_ urlString: String, for session: URLSession) {
        urlSession[session] = urlString
    }

    func removeSession(_ session: URLSession) {
        urlSession.removeValue(forKey: session)
    }

    func urlDownloading(_ urlString: String) -> Bool {
        if urlSession.existKey(forValue: urlString) != nil {
            return true
        } else {
            return false
        }
    }
}

extension Dictionary where Value: Equatable {
    func existKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}
