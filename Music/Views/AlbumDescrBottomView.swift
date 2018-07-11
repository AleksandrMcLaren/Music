//
//  AlbumDescrBottomView.swift
//  Music
//
//  Created by Aleksandr on 03.05.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

class AlbumDescrBottomView: UIView {

    public var object: DBAlbum? {
        didSet {
            reloadData()
        }
    }
    public var addedShadowEnabled = false

    @IBOutlet weak var padView: UIView!
    @IBOutlet weak var imView: ImageView! {
        didSet {
            imView.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = fontTextSmall
        }
    }
    @IBOutlet weak var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.font = fontTextSmall
        }
    }
    @IBOutlet weak var topConstraint: NSLayoutConstraint!

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

        if addedShadowEnabled == false {
            padView.configureShadow(cornerRadius: imView.layer.cornerRadius)
            return
        }

        padView.layer.shadowColor = UIColor.gray.cgColor
        padView.layer.shadowRadius = 6.0
        padView.layer.cornerRadius = 10.0

        if topConstraint.constant < 11.0 {
            padView.layer.shadowOffset = CGSize(width: 0, height: 5.0)
            padView.layer.shadowOpacity = 0.8
        } else {
            padView.layer.shadowOffset = CGSize.zero
            padView.layer.shadowOpacity = 0.15
        }
    }

    override func viewColors() {
        backgroundColor = cClear
        padView.backgroundColor = cBackground
        titleLabel.backgroundColor = cBackground
        subtitleLabel.backgroundColor = cBackground

        titleLabel.textColor = cHeadlines
        subtitleLabel.textColor = cSecondaryText
    }

    fileprivate func reloadData() {
        guard let album = object else {
            return
        }

        titleLabel.text = album.name
        subtitleLabel.text = album.peoplesList
        imView.urlString = album.cover
    }
}

extension AlbumDescrBottomView: TapGesture {

    func gestureTapped() {
        if let object = object {
            AppCoordinator.shared.pushCard(with: object)
        }
    }
}
