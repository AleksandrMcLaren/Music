//
//  Dictionary-Extension.swift
//  Music
//
//  Created by Aleksandr on 15.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation

extension Dictionary {

    func int64(by key: String) -> Int64 {
        var value: Int64 = 0

        if let dict = self as? [String: Any] {
            if let val = dict[key] as? String {
                value = Int64(val) ?? 0
            } else if let val = dict[key] as? Int {
                value = Int64(val)
            }
        }

        return value
    }

    func bool(by key: String) -> Bool {
        var value = false

        if let dict = self as? [String: Any], let val = dict[key] as? Int {
            value = (val == 1 ? true : false)
        }

        return value
    }
}
