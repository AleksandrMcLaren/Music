//
//  DataSource.swift
//  Music
//
//  Created by Aleksandr on 23.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

let rowContentInsets = TableDataSourceSection.rowContentInsets

protocol RowSource {
    var height: CGFloat? { get set }
    var heightScale: CGFloat { get set }
}

class TableDataSourceSection {
    /// Title
    public var title: String? {
        didSet {
            DispatchQueue.main.async {
                self.calculateTitleHeight()
            }
        }
    }
    public var titleHeight: CGFloat = 0

    private func calculateTitleHeight() {
        let headerView: SectionHeaderView = TableDataSourceSection.headerView
        headerView.titleText = title

        var frame = headerView.frame
        frame.size.width = TableDataSourceSection.screenWidth
        headerView.frame = frame
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()

        titleHeight = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    }

    /// Actions
    public var titleAction: (() -> Void)?

    /// Source
    public var source: [RowSource]?
    public var numberRows: Int {
        return source?.count ?? 0
    }

    /// Size
    public static let rowContentInsets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)

    public static let screenWidth = UIScreen.main.bounds.width
    public static let headerView: SectionHeaderView = SectionHeaderView.loadFromNib()
}

class TableDataSource: NSObject {

    var sections = [TableDataSourceSection]()
    /// DetailViewControllerPresentable
    var tableViewDidScroll: ((_ scrollView: UIScrollView) -> Void)!
    var tableViewWillEndDragging: ((_ scrollView: UIScrollView, _ velocity: CGPoint, _ targetContentOffset: UnsafeMutablePointer<CGPoint>) -> Void)!

    func table(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let dataSection = dataSection(indexPath.section),
            let sectionSource = dataSection.source {
            return table(tableView, sectionSource: sectionSource, cellForIndexPath: indexPath)
        }

        return tableView.emptyCell()
    }

    func table(_ tableView: UITableView, sectionSource: [Any], cellForIndexPath indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row < sectionSource.count {
            let rowSource = sectionSource[indexPath.row]

            if let source = rowSource as? SliderSource,
                let cell = tableView.sliderViewCell() as? SliderViewCell {
                source.configureCell(cell)

                switch source.type {
                case .collectionSquare?:
                    let itemSpacing: CGFloat = cell.minimumLineSpacing
                    let width = (tableView.frame.size.width - (rowContentInsets.left + rowContentInsets.right + itemSpacing)) / 2
                    let height = width + rowContentInsets.top + rowContentInsets.bottom
                    cell.itemSize = CGSize(width: width, height: height)
                case .albumSquare?:
                    let itemSpacing: CGFloat = cell.minimumLineSpacing
                    let width = (tableView.frame.size.width - (rowContentInsets.left + rowContentInsets.right) - itemSpacing) / 2
                    let height = width + 60.0 // под описание
                    cell.itemSize = CGSize(width: width, height: height)
                    source.height = height
                case .albumSquareCarousel?:
                    let itemSpacing: CGFloat = cell.minimumLineSpacing * 2
                    let width = (tableView.frame.size.width - itemSpacing * 2) / 1.8
                    let height = width + 70.0 // под описание
                    cell.itemSize = CGSize(width: width, height: height)
                    source.height = height
                    source.needsUpdateRows = { [unowned self] (source) in
                        self.tableView(tableView, replaceBottomRows: source, atIndexPath: indexPath)
                    }
                default:
                    let width = tableView.frame.size.width - (rowContentInsets.left + rowContentInsets.right)
                    let height = width * source.heightScale + rowContentInsets.top + rowContentInsets.bottom
                    cell.itemSize = CGSize(width: width, height: height)
                }

                return cell
            } else if let source = rowSource as? AlbumSource,
                let cell = tableView.albumViewCell() as? AlbumViewCell {
                source.configureCell(cell)
                return cell
            } else if let source = rowSource as? CollectionSource,
                let cell = tableView.collectionViewCell() as? CollectionViewCell {
                source.configureCell(cell)
                return cell
            } else if let source = rowSource as? TrackSource,
                let cell = tableView.trackViewCell() as? TrackViewCell {
                source.configureCell(cell)
                return cell
            } else if let source = rowSource as? TrackNumberSource,
                let cell = tableView.trackNumberViewCell() as? TrackNumberViewCell {
                source.configureCell(cell)
                return cell
            }  else if let _ = rowSource as? EmptySource,
                let cell = tableView.emptyViewCell() as? EmptyViewCell {
                return cell
            }
        }

        return tableView.emptyCell()
    }

    func dataSection(_ section: Int) -> TableDataSourceSection? {
        if section < sections.count {
            return sections[section]
        } else {
            return nil
        }
    }

    func table(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.section < sections.count {
            let section = sections[indexPath.section]

            if let sectionSource = section.source {
                return table(tableView, sectionSource: sectionSource, heightForRow: indexPath.row)
            }
        }

        return 0
    }

    func table(_ tableView: UITableView, sectionSource: [Any], heightForRow row: Int) -> CGFloat {

        if row < sectionSource.count, let rowSource = sectionSource[row] as? RowSource {
            if let height = rowSource.height {
                return height
            } else {
                let width = tableView.frame.size.width - (rowContentInsets.left + rowContentInsets.right)
                return width * rowSource.heightScale + rowContentInsets.top + rowContentInsets.bottom
            }
        }

        return 0
    }

    func tableView(_ tableView: UITableView, replaceBottomRows rowsSource: [RowSource]?, atIndexPath indexPath: IndexPath) {
        tableView.beginUpdates()

        let numberRows = tableView.numberOfRows(inSection: indexPath.section)

        if numberRows > 1 {
            var paths = [IndexPath]()

            for i in 1..<numberRows {
                let path = IndexPath.init(row: i, section: indexPath.section)
                paths.append(path)
            }

            tableView.deleteRows(at: paths, with: .bottom)
        }

        if indexPath.section < sections.count {
            let section = sections[indexPath.section]
            if let sectionSource = section.source {

                if sectionSource.count > 1 {
                    for _ in 1..<sectionSource.count {
                        section.source!.removeLast()
                    }
                }

                if let rowsSource = rowsSource {
                    var paths = [IndexPath]()

                    for i in 1..<(rowsSource.count + 1) {
                        let path = IndexPath.init(row: i, section: indexPath.section)
                        paths.append(path)
                    }

                    section.source!.append(contentsOf: rowsSource)
                    tableView.insertRows(at: paths, with: .top)
                }
            }
        }

        tableView.endUpdates()
    }
}

extension TableDataSource: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < self.sections.count {
            return self.sections[section].numberRows
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return table(tableView, cellForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if let dataSection = dataSection(section), let title = dataSection.title {
            let headerView: SectionHeaderView = SectionHeaderView.loadFromNib()
            headerView.titleText = title
            headerView.buttonHidden = dataSection.titleAction == nil
            headerView.tappedButton = {
                dataSection.titleAction?()
            }

            return headerView
        }

        return nil
    }
}

extension TableDataSource: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let dataSection = dataSection(section) {
            return dataSection.titleHeight
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if let dataSection = dataSection(section) {
            return dataSection.titleHeight
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return table(tableView, heightForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return table(tableView, heightForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
    }
}

extension TableDataSource: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tableViewDidScroll?(scrollView)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        tableViewWillEndDragging?(scrollView, velocity, targetContentOffset)
    }
}
