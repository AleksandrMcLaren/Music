//
//  AlbumDescriptionView.swift
//  Music
//
//  Created by Aleksandr on 20.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

class AlbumDescriptionView: UIView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel! {
        didSet {
            timeLabel.font = fontDescr
        }
    }

    override func viewColors() {
        backgroundColor = cElementBackground

       // timeLabel.backgroundColor = backgroundColor

       // timeLabel.textColor = cGray
    }
}
