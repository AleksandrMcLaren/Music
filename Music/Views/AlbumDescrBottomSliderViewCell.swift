//
//  AlbumDescrBottomSliderViewCell.swift
//  Music
//
//  Created by Aleksandr on 03.05.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

class AlbumDescrBottomSliderViewCell: UICollectionViewCell {

    var object: DBAlbum? {
        didSet {
            albumView.object = object
        }
    }

    lazy var albumView: AlbumDescrBottomView = {
        let view = AlbumDescrBottomView.loadFromNib() as AlbumDescrBottomView
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
