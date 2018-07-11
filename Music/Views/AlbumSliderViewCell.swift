//
//  AlbumSliderViewCell.swift
//  Music
//
//  Created by Aleksandr on 04.04.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

class AlbumSliderViewCell: UICollectionViewCell {

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
