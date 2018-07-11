//
//  SectionHeaderView.swift
//  Music
//
//  Created by Aleksandr on 23.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

class SectionHeaderView: UIView {

    public var titleText: String? {
        didSet {
            titleLabel.text = titleText
            setNeedsLayout()
        }
    }
    
    public var tappedButton: (() -> Void)?
    public var buttonHidden = false {
        didSet{
            button.isHidden = buttonHidden
        }
    }

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.numberOfLines = 0
            titleLabel.lineBreakMode = .byWordWrapping
            titleLabel.font = fontSection
        }
    }

    @IBOutlet weak var button: UIButton! {
        didSet {
            button.setTitle("button_more".lcd , for: .normal)
            button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
            button.titleLabel?.font = Font.shared.systemFont(ofSize: 17)
            button.titleLabel?.textAlignment = .right
            let insets = button.titleEdgeInsets
            button.titleEdgeInsets = UIEdgeInsets(top: insets.top, left: insets.left, bottom: insets.bottom, right: 20.0)
        }
    }

    override func viewColors() {
        backgroundColor = cBackground
        titleLabel.backgroundColor = cClear
        button.backgroundColor = cClear

        titleLabel.textColor = cHeadlines
        button.setTitleColor(cAdded, for: .normal)
    }

    @objc func tapped() {
        tappedButton?()
    }
}
