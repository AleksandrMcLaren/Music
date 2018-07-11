//
//  TrackViewCell.swift
//  Music
//
//  Created by Aleksandr on 31.01.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

class TrackViewCell: UITableViewCell {

//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }

    public var object: Any? {
        didSet {
            reloadData()
        }
    }

    public var tapped: (() -> Void)?

    @IBOutlet weak var imView: ImageView! {
        didSet {
            imView.layer.cornerRadius = 3
        }
    }
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = fontText
        }
    }
    @IBOutlet weak var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.font = fontDescr
        }
    }
    @IBOutlet weak var timeLabel: UILabel! {
        didSet {
            timeLabel.font = fontDescr
        }
    }
    @IBOutlet weak var downloadButton: UIButton! {
        didSet {
            downloadButton.setTitle("down", for: .normal)
            downloadButton.addTarget(self, action: #selector(downloadTapped), for: .touchUpInside)
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
        titleLabel.backgroundColor = cBackground
        subtitleLabel.backgroundColor = cBackground
        timeLabel.backgroundColor = cBackground

        titleLabel.textColor = cHeadlines
        subtitleLabel.textColor = cSecondaryText
        timeLabel.textColor = cSecondaryText
    }

    func reloadData() {

        guard let track = object as? DBTrack
            else { return }

        titleLabel.text = track.name
        subtitleLabel.text = track.peoplesList
        timeLabel.text = track.timeString()
        imView.urlString = track.cover
    }

    @objc func downloadTapped() {
        if let track = object as? DBTrack {
            track.download()
        }
    }

    @objc func viewTapped() {
        tapped?()
    }
}
