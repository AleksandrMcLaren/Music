//
//  Nib.swift
//  ARGame
//
//  Created by Aleksandr on 21/11/2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit

// MARK: - Nib

extension UIViewController {
    class func loadFromNib<T: UIViewController>() -> T {
        return T(nibName: String(describing: self), bundle: nil)
    }
}

// MARK: - Alert

extension UIViewController {

    func showAlertController(_ message: String?) {
        let alertController = UIAlertController(title: "alert_title_message".lcd, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Configure colors

extension UIViewController {

    static let classInit: Void = {
        let originalSelector = #selector(viewDidLoad)
        let swizzledSelector = #selector(swizzled_viewDidLoad)
        swizzling(UIViewController.self, originalSelector, swizzledSelector)
    }()

    @objc func swizzled_viewDidLoad() {
        swizzled_viewDidLoad()

        let sel = #selector(viewColors)

        if responds(to: sel) {
            perform(sel)
        }
    }

    @objc func viewColors() {}
}

// MARK: - Status Bar

extension UIViewController {

    private struct AssociatedKeys {
        static var barHidden = false
    }

    var statusBarHidden: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.barHidden) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.barHidden, newValue as Bool?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsStatusBarAppearanceUpdate()
        }
    }
}
