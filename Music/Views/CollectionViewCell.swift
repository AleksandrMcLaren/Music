//
//  CollectionViewCell.swift
//  Music
//
//  Created by Aleksandr on 30.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

class CollectionViewCell: UITableViewCell {

    deinit {
      //  print( " " )
    }

    public var isSquare = false {
        didSet {
            collectionView.isSquare = isSquare
        }
    }
    var object: DBCollection? {
        didSet {
            collectionView.object = object
        }
    }

    lazy var collectionView: CollectionView = {
        let view = CollectionView()
        addSubview(view)
        return view
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }

    override func viewColors() {
        backgroundColor = cClear
    }
}
