//
//  AlbumCardViewController.swift
//  Music
//
//  Created by Aleksandr on 23.01.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

protocol AlbumCardViewPresentation: class {
    func refreshing(_ value: Bool)
    func fetchCompletion(_ source: TableDataSource?)
}

class AlbumCardViewController: UIViewController, AlbumCardViewPresentation, PresentDetailPresentable {

    @IBOutlet weak var activityView: ActivityIndicatorView!
    @IBOutlet weak var tableView: TableView! {
        didSet {
            tableView.tableHeaderView = tableHeaderView
        }
    }

    fileprivate var dataSource: TableDataSource? {
        didSet{
            guard let dataSource = dataSource else {
                return
            }

            dataSource.tableViewDidScroll = tableViewDidScroll
            dataSource.tableViewWillEndDragging = tableViewWillEndDragging

            tableView.delegate = dataSource
            tableView.dataSource = dataSource
            tableView.reloadData()
        }
    }

    var presenter: AlbumCardPresentation?
    var tableHeaderView: UIView?
    var isNumberRows: Bool = false
    /// DetailViewControllerPresentable
    var tableViewDidScroll: ((_ scrollView: UIScrollView) -> Void)!
    var tableViewWillEndDragging: ((_ scrollView: UIScrollView, _ velocity: CGPoint, _ targetContentOffset: UnsafeMutablePointer<CGPoint>) -> Void)!

    fileprivate var data: [Any]?

    deinit {
        print("")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.masksToBounds = true

        configureViews()
        presenter?.fetch()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let height = view.bounds.height - (self.tabBarController?.tabBar.frame.height ?? 0)
        if tableView.contentSize.height < height {
            tableView.contentSize.height = height + 1
        }
    }

    override func viewColors() {
        view.backgroundColor = cBackground
        tableView.backgroundColor = cBackground
    }

    // MARK: - Configure

    func configureViews () {
        title = "tab_item_album".lcd
        navigationItem.largeTitleDisplayMode = .never
    }

    // MARK: - AlbumCardViewPresentation

    func refreshing(_ value: Bool) {
        if value == true {
            activityView.startAnimating()
        } else {
            activityView.stopAnimating()
        }
    }

    func fetchCompletion(_ source: TableDataSource?) {
        dataSource = source
    }
}
