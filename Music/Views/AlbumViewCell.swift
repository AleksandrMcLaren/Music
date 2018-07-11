//
//  AlbumViewCell.swift
//  Music
//
//  Created by Aleksandr on 20.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

class AlbumViewCell: UITableViewCell {

    var object: DBAlbum? {
        didSet {
            albumView.object = object
        }
    }

    lazy var albumView: AlbumView = {
        let view = AlbumView.loadFromNib() as AlbumView
        addSubview(view)
        return view
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        albumView.frame = bounds
    }

    override func viewColors() {
        backgroundColor = cClear
    }
}
