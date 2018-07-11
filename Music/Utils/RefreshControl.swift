//
//  ControlTableView.swift
//  Music
//
//  Created by Aleksandr on 01.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

protocol RefreshControlPresentable: class {
    /// Необходимо присвоить таблицу.
    /// На таблицу поставятся индикаторы загрузки.
    var tableView: UITableView? { get set }
    /// Переменная чтобы взять данные для таблицы.
    /// Данные заменяются/добавляются в методах refreshingTopComplete: и refreshingBottomComplete:
    var data: [Any] { get }

    /// Будет вызов когда сработал верхний индикаторы загрузки.
    /// Верхнего индикатора не будет если не реализовать refreshingTop:.
    var refreshingTop: (() -> Void)? { get set }
    /// Нужно вызвать когда получены новые данные.
    func refreshingTopComplete(with data: [Any]?)

    /// Нужно вызвать в методе tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    /// Если скролл на последней ячейке таблицы будет вызов refreshingBottom:
    func refreshBottomIfNeeded(forRowAt indexPath: IndexPath)
    var refreshingBottom: (() -> Void)? { get set }
    /// Нужно вызвать когда получены новые данные.
    func refreshingBottomComplete(with data: [Any]?)

    /// Нужно вызвать в методе scrollViewDidScroll(_ scrollView: UIScrollView)
    /// для изменения высоты вьюхи нижнего индикатора загрузки.
    func tableViewDidScroll(_ scrollView: UIScrollView)
}

class RefreshControl: RefreshControlPresentable {

    var tableView: UITableView?
    var data = [Any]()

    // MARK: Refresh top

    public var refreshingTop: (() -> Void)? {
        didSet {
            tableView?.refreshControl = UIRefreshControl()
            tableView?.refreshControl?.addTarget(self, action: #selector(refreshTopAction), for: .valueChanged)
        }
    }

    @objc func refreshTopAction() {
        refreshingTop?()
    }

    public func refreshingTopComplete(with topData: [Any]?) {
        self.tableView?.refreshControl?.endRefreshing()

        if let topData = topData {
            data.removeAll()
            data.append(contentsOf: topData)
            self.tableView?.reloadData()
        }
    }

    // MARK: Refresh bottom

    public var refreshingBottom: (() -> Void)?
    fileprivate var bottomActivityView: UIView?

    fileprivate lazy var bottomIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]
        return indicator
    }()

    public func refreshBottomIfNeeded(forRowAt indexPath: IndexPath) {
        let lastSection = (tableView?.numberOfSections ?? 1) - 1
        let numberOfRowsInSection = tableView?.numberOfRows(inSection: lastSection) ?? 0
        let lastRow = numberOfRowsInSection - 1

        if indexPath.section == lastSection,
            indexPath.row == lastRow {

            if refreshingBottom != nil, bottomActivityView == nil {
                refreshBottom()
            }
        }
    }

    public func tableViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        let bounds = scrollView.bounds
        let size = scrollView.contentSize
        let inset = scrollView.contentInset
        let y = offset.y + bounds.size.height - inset.bottom
        let distance = y - size.height

        if distance > 0 {
            if bottomActivityView != nil {
                setBottomActivityViewHeight(distance)
            }
        }
    }

    fileprivate func refreshBottom() {
        addBottomActivityView()
        refreshingBottom?()
    }

    public func refreshingBottomComplete(with data: [Any]?) {
        DispatchQueue.main.async {
            if let data = data, !data.isEmpty {
                self.addData(data)
            } else {
                self.removeBottomActivityView()
            }
        }
    }

    fileprivate func addBottomActivityView() {
        let frame = CGRect(x: 0, y: 0, width: tableView?.frame.size.width ?? 0, height: 50)
        bottomActivityView = UIView(frame: frame)

        if let view = bottomActivityView {
            bottomIndicator.center = view.center
            view.addSubview(bottomIndicator)

            tableView?.tableFooterView = bottomActivityView
            bottomIndicator.startAnimating()
        }
    }

    fileprivate func removeBottomActivityView() {
        bottomIndicator.stopAnimating()
        bottomActivityView?.removeFromSuperview()
        tableView?.tableFooterView = nil
        bottomActivityView = nil
    }

    fileprivate func setBottomActivityViewHeight(_ height: CGFloat) {
        if let view: UIView = bottomActivityView {
            var frame = view.frame
            frame.size.height = 50 + height
            view.frame = frame
        }
    }

    fileprivate func addData(_ bottomData: [Any]) {
        let nextRow = data.count
        let end = nextRow + bottomData.count
        var paths = [IndexPath]()

        for i in nextRow..<end {
            let path = IndexPath(row: i, section: 0)
            paths.append(path)
        }

        if !paths.isEmpty {
            CATransaction.begin()

            CATransaction.setCompletionBlock {
                self.removeBottomActivityView()
            }

            tableView?.beginUpdates()
            data.append(contentsOf: bottomData)
            tableView?.insertRows(at: paths, with: .none)
            tableView?.endUpdates()

            CATransaction.commit()
        } else {
            removeBottomActivityView()
        }
    }
}
