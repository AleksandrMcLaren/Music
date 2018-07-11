//
//  TapGestureRecognizer-Extension.swift
//  Music
//
//  Created by Aleksandr on 30.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

import UIKit

@objc protocol TapGesture {
    var tapGesture: UITapGestureRecognizer? { get set }
    func gestureTapped()
}

extension TapGesture where Self: UIView {

    func addTapGesture() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(gestureTapped))

        if let tapGesture = tapGesture {
            addGestureRecognizer(tapGesture)
        }
    }


    func removeTapGesture() {
        if let tapGesture = tapGesture {
            removeGestureRecognizer(tapGesture)
        }
    }

    func gestureTapped() {}
}
