//
//  HorizontalList.swift
//  Music
//
//  Created by Aleksandr on 22.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

class SliderViewCell: UITableViewCell {
    public var items: [Any]!
    public var configureCell: ((_ cell: UICollectionViewCell, _ item: Any) -> (Swift.Void))?
    public var didScrollToItem: ((Int) -> (Swift.Void))?
    public var scrollViewDidScroll: (() -> (Swift.Void))?
    public var countItemScrollOnSwipe = 1
    public var minimumLineSpacing: CGFloat = 0.0 {
        didSet {
            flowLayout.minimumLineSpacing = minimumLineSpacing
        }
    }
    public var infiniteScrollEnabled = false {
        didSet {
            if infiniteScrollEnabled != oldValue {
                flowLayout.centerItemEnabled = infiniteScrollEnabled
            }
        }
    }
    public var itemSize: CGSize = CGSize.zero {
        didSet {
            flowLayout.itemSize = itemSize
        }
    }
    public var firstItemIndex: Int = 0 {
        didSet {
            scrollToCurrentIndex()
        }
    }

    fileprivate var cellReuseId = ""
    fileprivate var indexOfCellBeforeDragging = 0
    fileprivate let infiniteSize = 1000

    lazy var flowLayout: CollectionViewFlowLayoutCenterItem = {
        let flowLayout = CollectionViewFlowLayoutCenterItem()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = minimumLineSpacing
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20.0, bottom: 0, right: 20.0)
        flowLayout.itemSize = itemSize
        flowLayout.estimatedItemSize = itemSize
        return flowLayout
    }()

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        return collectionView
    }()

    public func register(_ cellClass: Swift.AnyClass?, forCellReuseIdentifier identifier: String) {
        cellReuseId = identifier
        collectionView.register(cellClass, forCellWithReuseIdentifier: cellReuseId)
    }

    public func reloadData() {
        collectionView.reloadData()
    }

    internal override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }

    internal override func viewColors() {
        backgroundColor = cBackground
        collectionView.backgroundColor = cBackground
    }

    fileprivate func indexOfMajorCell() -> Int {
        let itemWidth = itemSize.width + minimumLineSpacing
        let proportionalOffset = (collectionView.contentOffset.x) / itemWidth
        return Int(round(proportionalOffset))
    }

    fileprivate func scrollToCurrentIndex() {
        if self.infiniteScrollEnabled {
            var firstRow = self.infiniteSize / 2
            let rowsAfterFirstRow = firstRow % self.items.count
            firstRow = firstRow - rowsAfterFirstRow + self.firstItemIndex
            let path = IndexPath(row: firstRow, section: 0)
            DispatchQueue.main.async {
                self.collectionView.scrollToItem(at: path, at: .centeredHorizontally, animated: false)

                DispatchQueue.main.async {
                    self.scrollViewDidScroll?()
                }
            }
        } else {
            DispatchQueue.main.async {
                let offset = (self.itemSize.width + self.flowLayout.minimumLineSpacing) * CGFloat(self.firstItemIndex)
                let newRect = CGRect(x: offset, y: 0, width: self.collectionView.frame.size.width, height: self.collectionView.frame.size.height)
                self.collectionView.scrollRectToVisible(newRect, animated: false)
            }
        }
    }
}

extension SliderViewCell: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return infiniteScrollEnabled ? infiniteSize : items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseId, for: indexPath)
        let row = infiniteScrollEnabled ? (indexPath.row % items.count) : indexPath.row

        if row < items.count {
            configureCell?(cell, items[row])
        }

        return cell
    }
}

extension SliderViewCell: UICollectionViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        indexOfCellBeforeDragging = indexOfMajorCell()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        guard infiniteScrollEnabled == false else {
            return
        }

        var snapToIndex = 0

        if (velocity.x == 0) { // slow dragging not lifting finger
            snapToIndex = Int(floor((targetContentOffset.pointee.x - (itemSize.width + minimumLineSpacing) / 2) / (itemSize.width + minimumLineSpacing)) + 1);
            let toValue = (itemSize.width + minimumLineSpacing) * CGFloat(snapToIndex)
            targetContentOffset.pointee = CGPoint(x: toValue, y: 0)
        } else {
            let swipeVelocityThreshold: CGFloat = 0.2 // after some trail and error
            let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging < items.count && velocity.x > swipeVelocityThreshold
            snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? countItemScrollOnSwipe : -countItemScrollOnSwipe)

            if snapToIndex > -1 && snapToIndex < collectionView.numberOfItems(inSection: 0) {

                //            DispatchQueue.main.async {
                //                // Stop scrollView sliding:
                //                targetContentOffset.pointee = scrollView.contentOffset
                //               self.flowLayout.collectionView!.scrollRectToVisible(newRect, animated: true)
                //            }

                let toValue = (itemSize.width + minimumLineSpacing) * CGFloat(snapToIndex)
                let newRect = CGRect(x: toValue, y: 0, width: self.collectionView.frame.size.width, height: self.collectionView.frame.size.height)
                targetContentOffset.pointee = newRect.origin

                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
                    self.collectionView.scrollRectToVisible(newRect, animated: false)
                    // scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                    // scrollView.layoutIfNeeded()
                }, completion: nil)
            }
        }

        didScrollToItem?(snapToIndex)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScroll?()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let row = indexOfMajorCell() % items.count
        didScrollToItem?(row)
    }
}
