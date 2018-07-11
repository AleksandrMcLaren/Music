//
//  Font.swift
//  Music
//
//  Created by Aleksandr on 20.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

let fontText = Font.shared.text()
let fontTextSmall = Font.shared.textSmall()
let fontDescr = Font.shared.description()
let fontSection = Font.shared.section()

class Font {

    public static let shared = Font()
    private init() {}

    func section() -> UIFont {
        return mediumFont(ofSize: 24.0)
    }

    func text() -> UIFont{
        return systemFont(ofSize: 17.0)
    }

    func textSmall() -> UIFont{
        return systemFont(ofSize: 15.0)
    }

    func description() -> UIFont{
        return systemFont(ofSize: 13.0)
    }

    public func lightFont(ofSize fontSize: CGFloat) -> UIFont {
        if let font = UIFont(name: "MuseoCyrl-100", size: fontSize) {
            return font
        } else {
            return UIFont.systemFont(ofSize: fontSize)
        }
    }

    public func mediumFont(ofSize fontSize: CGFloat) -> UIFont {
        if let font = UIFont(name: "MuseoCyrl-300", size: fontSize) {
            return font
        } else {
            return UIFont.boldSystemFont(ofSize: fontSize)
        }
    }

    public func systemFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.regular)
    }
}
