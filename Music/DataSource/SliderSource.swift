//
//  HorizontalListSource.swift
//  Music
//
//  Created by Aleksandr on 23.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

enum SliderSourceType: Int {
    case album
    case albumSquare
    case albumSquareCarousel
    case collection
    case collectionSquare
}

class SliderSource: RowSource {

    // MARK: - Configure cell
    
    public var data: [Any]?
    public var currentItemIndex: Int = 0
    public var height: CGFloat?
    public var heightScale: CGFloat = 0.5
    public var type: SliderSourceType?
    public var needsUpdateRows: (([RowSource]?) -> (Swift.Void))?

    public func configureCell(_ slider: SliderViewCell) {

        guard let data = data, let type = type else {
            return
        }

        slider.minimumLineSpacing = 10.0
        slider.countItemScrollOnSwipe = 1
        slider.infiniteScrollEnabled = false
        slider.didScrollToItem = { [weak self] (index) in
            self?.currentItemIndex = index
        }
        slider.scrollViewDidScroll = nil

        if type == .album {
            configureForAlbum(slider)
        } else if type == .albumSquare {
            configureForAlbumSquare(slider)
        } else if type == .albumSquareCarousel {
            configureForAlbumCarousel(slider)
        } else if type == .collection || type == .collectionSquare {
            configureForCollection(slider)
        }

        slider.items = data
        slider.reloadData()
        slider.firstItemIndex = currentItemIndex
    }

    func configureForAlbum(_ slider: SliderViewCell) {
        slider.register(AlbumSliderViewCell.self, forCellReuseIdentifier: "albumId")
        slider.configureCell = { (cell, item) in
            if let cell = cell as? AlbumSliderViewCell {
                cell.albumView.leadingConstraint.constant = 0
                cell.albumView.trailingConstraint.constant = 0
                cell.object = item as? DBAlbum
            }
        }
    }

    func configureForAlbumSquare(_ slider: SliderViewCell) {
        slider.minimumLineSpacing = 10.0
        slider.register(AlbumDescrBottomSliderViewCell.self, forCellReuseIdentifier: "albumSquareId")
        slider.configureCell = { (cell, item) in
            if let cell = cell as? AlbumDescrBottomSliderViewCell {
                cell.albumView.addedShadowEnabled = false
                cell.albumView.topConstraint.constant = 10.0
                cell.albumView.layoutIfNeeded()
                cell.albumView.setNeedsDisplay()
                cell.object = item as? DBAlbum
            }
        }
    }

    func configureForAlbumCarousel(_ slider: SliderViewCell) {
        slider.minimumLineSpacing = 20.0
        slider.infiniteScrollEnabled = true
        slider.register(AlbumDescrBottomSliderViewCell.self, forCellReuseIdentifier: "albumSquareId")
        slider.configureCell = { (cell, item) in
            if let cell = cell as? AlbumDescrBottomSliderViewCell {
                cell.albumView.addedShadowEnabled = true
                cell.object = item as? DBAlbum
            }
        }
        slider.scrollViewDidScroll = { [unowned slider] in
            let visibleCellPaths = slider.collectionView.indexPathsForVisibleItems
            let supreviewWidth = slider.collectionView.superview?.frame.width ?? 0

            for path in visibleCellPaths {
                if let attr = slider.collectionView.layoutAttributesForItem(at: path),
                    let cell = slider.collectionView.cellForItem(at: path) as? AlbumDescrBottomSliderViewCell {
                    let cellX = slider.collectionView.convert(attr.frame, to: slider).origin.x
                    let half = (supreviewWidth - cell.frame.width) / 2
                    let left = half - 20.0
                    let right = half + 20.0
                  
                    if cellX > left && cellX < right {
                        if cell.albumView.topConstraint.constant != 10.0 {
                            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                                cell.albumView.topConstraint.constant = 10.0
                                cell.albumView.layoutIfNeeded()
                                cell.albumView.setNeedsDisplay()
                            }, completion: nil)
                        }
                    } else {
                        if cell.albumView.topConstraint.constant != 20.0 {
                            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                                cell.albumView.topConstraint.constant = 20.0
                                cell.albumView.layoutIfNeeded()
                                cell.albumView.setNeedsDisplay()
                            }, completion: nil)
                        }
                    }
                }
            }
        }
        slider.didScrollToItem = { [weak self] (index) in
            if let _self = self, _self.currentItemIndex != index {
                _self.currentItemIndex = index
                tableChangeListTracks(with: index)
            }
        }

        func tableChangeListTracks(with albumIndex: Int) {
            if let data = data, albumIndex < data.count, let album = data[albumIndex] as? DBAlbum {
                if let tracks = album.tracks, tracks.count > 0 {
                    let list = Array(tracks.prefix(3))
                    let sourceRows = TrackSource().tracks(with: list, parentObject: list)
                    needsUpdateRows?(sourceRows)
                } else {
                    needsUpdateRows?(nil)
                }
            }
        }
    }

    func configureForCollection(_ slider: SliderViewCell) {
        //slider.countItemScrollOnSwipe = (type == .collectionSquare ? 2 : 1)
        slider.register(CollectionSliderViewCell.self, forCellReuseIdentifier: "collectionId")
        slider.configureCell = { (cell, item) in
            if let cell = cell as? CollectionSliderViewCell {
                cell.collectionView.leadingConstant = 0
                cell.collectionView.trailingConstant = 0
                cell.object = item as? DBCollection
            }
        }
    }

    // MARK: - Create source

    func slider(with objects: [Any]) -> SliderSource {
        let source = SliderSource()
        source.data = objects
        return source
    }
}
