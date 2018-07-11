//
//  Color.swift
//  Music
//
//  Created by Aleksandr on 16.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

let cBackground = Color.shared.scheme.background
let cElementBackground = Color.shared.scheme.elementBackground
let cHeadlines = Color.shared.scheme.headlines
let cSecondaryText = Color.shared.scheme.secondaryText
let cClear = Color.shared.scheme.clear
let cAdded = Color.shared.scheme.added
let cSeparatar = Color.shared.scheme.separator

enum ColorViewScheme: Int {
    case light
    case dark
}

class Color {

    public static let shared = Color()
    private init() {
        configureScheme()
    }

    public var settingLightScheme: Bool {
        if let s = UserDefaults.standard.value(forKey: colorSchemeKey) as? Int {
            return s == ColorViewScheme.light.rawValue
        } else {  
            /// по умолчанию light схема
            return true
        }
    }

    public func setScheme(_ scheme: ColorViewScheme) {
        UserDefaults.standard.set(scheme.rawValue, forKey: colorSchemeKey)
        configureScheme()
    }

    fileprivate var scheme: ColorScheme!
    fileprivate let colorSchemeKey = "ColorSchemeKey"

    fileprivate lazy var lightScheme: ColorScheme = {
        return LightScheme()
    }()

    fileprivate lazy var darkScheme: ColorScheme = {
        return DarkScheme()
    }()

    fileprivate func configureScheme() {
        if settingLightScheme {
            scheme = lightScheme
        } else {
            scheme = darkScheme
        }
    }
}

protocol ColorScheme {
    var background: UIColor { get }
    var elementBackground: UIColor { get }
    var headlines: UIColor { get }
    var secondaryText: UIColor { get }
    var clear: UIColor { get }
    var added: UIColor { get }
    var separator: UIColor { get }
}

class LightScheme: ColorScheme {
    let background = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.00)
    let elementBackground = UIColor.init(red:0.98, green:0.98, blue:0.98, alpha:1.00)
    let headlines = UIColor.init(red:0.0, green:0.0, blue:0.0, alpha:1.00)
    let secondaryText = UIColor.init(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
    let clear = UIColor.clear
    let added = UIColor.init(red: 0.0, green: 0.67, blue: 1.0, alpha: 1.0)
    let separator = UIColor.init(red: 0.74, green: 0.73, blue: 0.76, alpha: 1.0)
}

class DarkScheme: ColorScheme {
    let background = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.00)
    let elementBackground = UIColor.init(red:0.12, green:0.15, blue:0.2, alpha:1.00)
    let headlines = UIColor.init(red:0.98, green:0.98, blue:0.98, alpha:1.00)
    let secondaryText = UIColor.init(red: 0.89, green: 0.9, blue: 0.92, alpha: 1.0)
    let clear = UIColor.clear
    let added = UIColor.init(red: 0.0, green: 0.67, blue: 1.0, alpha: 1.0)
    let separator = UIColor.init(red: 0.74, green: 0.73, blue: 0.76, alpha: 1.0)
}
