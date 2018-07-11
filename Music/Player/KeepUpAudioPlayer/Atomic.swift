//
//  Atomic.swift
//  Music
//
//  Created by Aleksandr on 15.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation

class Atomic<T> {

    fileprivate var _val: T
    fileprivate var val_mutex = pthread_mutex_t()

    init (value: T) {
        pthread_mutex_init(&val_mutex, nil)
        _val = value
    }

    deinit {
        pthread_mutex_destroy(&val_mutex)
    }

    var value: T {
        get {
            pthread_mutex_lock(&val_mutex)
            let result = _val
            defer {
                pthread_mutex_unlock(&val_mutex)
            }
            return result
        }

        set (newValue) {
            pthread_mutex_lock(&val_mutex)
            _val = newValue
            pthread_mutex_unlock(&val_mutex)
        }
    }
}
