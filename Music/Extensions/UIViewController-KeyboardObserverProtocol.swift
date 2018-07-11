//
//  UIViewController-KeyboardObserverProtocol.swift
//  ARGame
//
//  Created by Aleksandr on 28/11/2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit

@objc protocol KeyboardNotification {
    func keyboardWillChangeFrame(notification: NSNotification)
}

extension KeyboardNotification {

    func addKeyboardNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(Self.keyboardWillChangeFrame),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
    }

    func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                                  object: nil)
    }

    func keyboardWillChangeFrame(notification: NSNotification) {}
}
