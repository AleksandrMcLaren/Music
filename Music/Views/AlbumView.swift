//
//  AlbumView.swift
//  Music
//
//  Created by Aleksandr on 22.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

class AlbumView: UIView {

    public var object: DBAlbum? {
        didSet {
            reloadData()
        }
    }

    @IBOutlet weak var imView: ImageView!
    @IBOutlet weak var descView: AlbumDescriptionView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!

    var tapGesture: UITapGestureRecognizer?

    override func awakeFromNib() {
        super.awakeFromNib()
        addTapGesture()
    }

    deinit {
        removeTapGesture()
    }

    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        configureShadow()
    }

    override func viewColors() {
        backgroundColor = cClear
    }

    fileprivate func reloadData() {
        guard let album = object else {
            return
        }

        imView.urlString = album.cover

        //  descrView.timeLabel.text = album.timeString()
    }
}

extension AlbumView: TapGesture {

    func gestureTapped() {
        if let object = object {
            AppCoordinator.shared.pushCard(with: object)
        }
    }
}
