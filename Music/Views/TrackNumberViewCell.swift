//
//  TrackNumberViewCell.swift
//  Music
//
//  Created by Aleksandr on 03.04.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

class TrackNumberViewCell: UITableViewCell {

    public var object: Any? {
        didSet {
            reloadData()
        }
    }

    public var tapped: (() -> Void)?

    @IBOutlet weak var numberLabel: UILabel! {
        didSet {
            numberLabel.font = fontText
        }
    }
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = fontText
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
    }

    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            let y = frame.height - 0.5
            let start = CGPoint(x: titleLabel.frame.origin.x - 3, y: y)
            let end = CGPoint(x: frame.width - 20, y: y)

            context.setLineWidth(0.5)
            context.setStrokeColor(cSeparatar.cgColor)
            context.move(to: CGPoint(x: start.x, y: start.y))
            context.addLine(to: CGPoint(x: end.x, y: end.y))
            context.strokePath()
        }
    }

    override func viewColors() {
        backgroundColor = cBackground
        numberLabel.backgroundColor = cBackground
        titleLabel.backgroundColor = cBackground

        numberLabel.textColor = cSecondaryText
        titleLabel.textColor = cHeadlines
    }

    func reloadData() {

        guard let track = object as? DBTrack
            else { return }

        if let album = track.album, let tracks = album.tracks?.array as? [DBTrack],
            let number = tracks.index(of: track) {
            numberLabel.text = String(describing: number + 1)
        }

        titleLabel.text = track.name
    }

    @objc func viewTapped() {
        tapped?()
    }
}
