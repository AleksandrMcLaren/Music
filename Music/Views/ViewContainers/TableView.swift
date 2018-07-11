//
//  TableView.swift
//  Music
//
//  Created by Aleksandr on 19.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

let albumViewCellId = "AlbumViewCell"
let trackViewCellId = "TrackViewCell"
let trackNumberViewCellId = "TrackNumberViewCell"
let collectionViewCellId = "CollectionViewCell"
let sliderViewCellId = "SliderViewCell"
let emptyCellId = "emptyCell"

class TableView: UITableView {

    override func awakeFromNib() {
        super.awakeFromNib()

        configureView()
        registerViewCells()
        updateContentInset()
        addMiniPlayerLayoutNotification()
    }

    deinit {
        removeMiniPlayerLayoutNotification()
    }

    func registerViewCells() {
        register(AlbumViewCell.self, forCellReuseIdentifier: albumViewCellId)
        register(CollectionViewCell.self, forCellReuseIdentifier: collectionViewCellId)
        register(SliderViewCell.self, forCellReuseIdentifier: sliderViewCellId)
        register(EmptyViewCell.self, forCellReuseIdentifier: emptyCellId)
        register(UINib(nibName: "TrackViewCell", bundle: nil), forCellReuseIdentifier: trackViewCellId)
        register(UINib(nibName: "TrackNumberViewCell", bundle: nil), forCellReuseIdentifier: trackNumberViewCellId)
    }

    func updateContentInset() {
        let inset = contentInset
        contentInset = UIEdgeInsets(top: inset.top, left: inset.left, bottom: MiniPlayer.height(), right: inset.right)
        scrollIndicatorInsets = contentInset
    }

    func configureView() {
        separatorStyle = .none
        /// уберем сепараторы пустых строк для карточек
        tableFooterView = UIView()
    }
}

extension TableView: MiniPlayerNotification {

    func miniPlayerLayout() {
        DispatchQueue.main.async {
            self.updateContentInset()
        }
    }
}

extension UITableView {

    func albumViewCell() -> UITableViewCell? {
        return dequeueReusableCell(withIdentifier: albumViewCellId)
    }

    func trackViewCell() -> UITableViewCell? {
        return dequeueReusableCell(withIdentifier: trackViewCellId)
    }

    func trackNumberViewCell() -> UITableViewCell? {
        return dequeueReusableCell(withIdentifier: trackNumberViewCellId)
    }

    func collectionViewCell() -> UITableViewCell? {
        return dequeueReusableCell(withIdentifier: collectionViewCellId)
    }

    func sliderViewCell() -> UITableViewCell? {
        return dequeueReusableCell(withIdentifier: sliderViewCellId)
    }

    func emptyViewCell() -> UITableViewCell? {
        return dequeueReusableCell(withIdentifier: emptyCellId)
    }

    func emptyCell() -> UITableViewCell {
        return UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: emptyCellId)
    }
}
