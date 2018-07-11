//
//  AlbumCardHeaderView.swift
//  Music
//
//  Created by Aleksandr on 06.02.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

protocol AlbumCardHeaderPresentation: class {
    var buttonSelected: Bool { get set }
    var repeatText: String { get set }
    var shuffleText: String { get set }
    var cover: String? { get set }
}

class AlbumCardHeaderView: UIView, AlbumCardHeaderPresentation {

    @IBOutlet weak var imView: ImageView!
    @IBOutlet weak var playButton: UIButton! {
        didSet {
            playButton.setImage(UIImage(named: "album_card_play_button"), for: .normal)
            playButton.setImage(UIImage(named: "album_card_pause_button"), for: .selected)
            playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        }
    }
    @IBOutlet weak var previouseButton: UIButton! {
        didSet {
            previouseButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
        }
    }
    @IBOutlet weak var nextButton: UIButton! {
        didSet {
            nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        }
    }
    @IBOutlet weak var endTrack: UIButton! {
        didSet {
            endTrack.addTarget(self, action: #selector(endTrackTapped), for: .touchUpInside)
        }
    }
    @IBOutlet weak var repeatButton: UIButton! {
        didSet {
            repeatButton.addTarget(self, action: #selector(repeatTapped), for: .touchUpInside)
        }
    }
    @IBOutlet weak var repeatLabel: UILabel!

    @IBOutlet weak var shuffleButton: UIButton! {
        didSet {
            shuffleButton.addTarget(self, action: #selector(shuffleTapped), for: .touchUpInside)
        }
    }
    @IBOutlet weak var shuffleLabel: UILabel!

    @IBOutlet weak var downloadButton: UIButton! {
        didSet {
            downloadButton.setTitle("down", for: .normal)
            downloadButton.addTarget(self, action: #selector(downloadTapped), for: .touchUpInside)
        }
    }

    var presenter: AlbumCardPresentation?

    var cover: String? {
        didSet {
            imView.urlString = cover
        }
    }

    var buttonSelected = false {
        didSet {
            playButton.isSelected = buttonSelected
        }
    }

    var repeatText: String = "" {
        didSet {
            repeatLabel.text = repeatText
        }
    }

    var shuffleText: String = "" {
        didSet {
            shuffleLabel.text = shuffleText
        }
    }

    // MARK: - Actions
    @objc func playTapped() {
        presenter?.playTapped()
    }

    @objc func prevTapped() {
        presenter?.prevTapped()
    }

    @objc func nextTapped() {
        presenter?.nextTapped()
    }

    @objc func endTrackTapped() {
        presenter?.endTapped()
    }

    @objc func repeatTapped() {
        presenter?.repeatTapped()
    }

    @objc func shuffleTapped() {
        presenter?.shuffleTapped()
    }

    @objc func downloadTapped() {
        presenter?.downloadTapped()
    }
}
