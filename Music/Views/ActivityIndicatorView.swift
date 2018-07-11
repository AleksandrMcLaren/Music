//
//  ActivityIndicatorView.swift
//  Music
//
//  Created by Aleksandr on 09.04.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

class ActivityIndicatorView: UIActivityIndicatorView {

    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    func configure() {
        hidesWhenStopped = true
        activityIndicatorViewStyle = .gray
    }
}
