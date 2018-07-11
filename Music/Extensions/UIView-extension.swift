//
//  UIView-extension.swift
//  Music
//
//  Created by Aleksandr on 06.02.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

// MARK: Nib

extension UIView {
    static func loadFromNib<T: UIView>() -> T {
        return (Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)?[0] as? T) ?? T()
    }
}

// MARK: viewColors

let swizzling: (AnyClass, Selector, Selector) -> () = { forClass, originalSelector, swizzledSelector in
    let originalMethod = class_getInstanceMethod(forClass, originalSelector)
    let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)

    if let originalMethod = originalMethod,
        let swizzledMethod = swizzledMethod {
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension UIView {

    static let classInit: Void = {
        let originalSelector = #selector(willMove(toWindow:))
        let swizzledSelector = #selector(swizzled_willMove(toWindow:))
        swizzling(UIView.self, originalSelector, swizzledSelector)
    }()

    @objc func swizzled_willMove(toWindow newWindow: UIWindow?) {
        swizzled_willMove(toWindow: newWindow)

        let sel = #selector(viewColors)

        if responds(to: sel) {
            perform(sel)
        }
    }

    @objc func viewColors() {}
}

extension UIView {

    private func getSubviewsOf<T : UIView>(view:UIView) -> [T] {
        var subviews = [T]()

        for subview in view.subviews {
            subviews += getSubviewsOf(view: subview) as [T]

            if let subview = subview as? T {
                subviews.append(subview)
            }
        }

        return subviews
    }
}

// MARK: Shadow

extension UIView {

    func configureShadow() {
        configureShadow(cornerRadius: 10.0)
    }

    func configureShadow(cornerRadius: CGFloat) {
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 6.0
        layer.cornerRadius = cornerRadius

//                    layer.shadowColor = UIColor.gray.cgColor
//                    layer.shadowOffset = CGSize.zero
//                    layer.shadowOpacity = 0.3
//                    layer.shadowRadius = 14.0
//                    layer.cornerRadius = 10.0
    }
}
