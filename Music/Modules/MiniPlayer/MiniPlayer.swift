//
//  MiniPlayer.swift
//  Music
//
//  Created by Aleksandr on 07.02.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

protocol MiniPlayerPresentable: class {
    func show(in parentView: UIView, startFrame: CGRect, endFrame: CGRect)
    func hide()
    /// Высота плеера. В контроллерах использовать для contentInset.
    static func height() -> CGFloat
}

class MiniPlayer: UIView, MiniPlayerPresentable {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureViews()
    }

    deinit {
        removePlayContentNotifications()
    }

    @IBOutlet weak var playButton: UIButton! {
        didSet {
            playButton.setImage(UIImage(named: "album_card_play_button"), for: .normal)
            playButton.setImage(UIImage(named: "album_card_pause_button"), for: .selected)
            playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        }
    }
    @IBOutlet weak var peopleLabel: UILabel!
    @IBOutlet weak var trackLabel: UILabel!

    var track: DBTrack?

    func configureViews() {
        backgroundColor = .gray
        layer.masksToBounds = true

        addPlayContentNotifications()
    }

    func reloadData() {

        playButton.isSelected = player.playing

        if let currentTrack = track,
            let playerCurentTrack = player.playContent?.currentTrack,
            currentTrack == playerCurentTrack {
            return
        }

        track = player.playContent?.currentTrack

        if let track = player.playContent?.currentTrack {
            peopleLabel.text = track.peoplesList
            trackLabel.text = track.name
        }
    }

    // MARK: MiniPlayerPresentation
    func show(in parentView: UIView, startFrame: CGRect, endFrame: CGRect) {

        frame = startFrame
        parentView.addSubview(self)

        animateToFrame(endFrame)
    }

    func hide() {
        let endFrame = CGRect(x: 0, y: frame.origin.y + frame.size.height, width: frame.size.width, height: 0)
        animateToFrame(endFrame)
    }

    static func height() -> CGFloat {
        return miniPlayerHeight
    }

    // MARK: Action
    @objc func playTapped() {
        if player.playing == true {
            player.pause()
        } else {
            player.play()
        }
    }
}

extension MiniPlayer {

    fileprivate static var miniPlayerHeight: CGFloat = 0

    func animateToFrame(_ frame: CGRect) {

        DispatchQueue.main.async {

            UIView.animate(withDuration: 0.45,
                           delay: 0.08,
                           usingSpringWithDamping: 0.75,
                           initialSpringVelocity: 1.0,
                           options: .layoutSubviews,
                           animations: {
                            self.frame = frame
            }, completion: { (finished) in
                MiniPlayer.miniPlayerHeight = self.frame.height
                NotificationCenter.default.post(name: MiniPlayerLayoutNotificationName,
                                                object: self)
            })
        }
    }
}

extension MiniPlayer: PlayContentNotification {

    func playContentChanged() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
}
