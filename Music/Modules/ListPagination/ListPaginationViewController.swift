//
//  AlbumListNewsViewController.swift
//  Music
//
//  Created by Aleksandr on 28.02.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit


class ListPaginationViewController: UIViewController {

    @IBOutlet weak var tableView: TableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    @IBOutlet weak var activityView: ActivityIndicatorView!

    public var fetchData: ((Int, ((_ data: [RowSource]?) -> Swift.Void)?) -> Void)?
    public var backButtonTitle: String?

    fileprivate var page: Int = 1
    fileprivate let refreshControl: RefreshControlPresentable = RefreshControl()
    fileprivate var data: [Any] {
        return refreshControl.data
    }
    fileprivate let calcDataSource = TableDataSource()

    deinit {
        print(" ")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let backButtonTitle = backButtonTitle {
            navigationController?.navigationBar.topItem?.backBarButtonItem  = UIBarButtonItem(title: backButtonTitle, style: .plain, target: nil, action:
                nil)
        }

        loadFirstData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    // MARK: - Configure

    override func viewColors() {
        view.backgroundColor = cBackground
        tableView.backgroundColor = cBackground
    }

    fileprivate func configureRefreshControl() {

        refreshControl.tableView = tableView

        refreshControl.refreshingTop = { [weak self] in
            self?.fetch(with: 1, completion: { (data) in
                self?.refreshControl.refreshingTopComplete(with: data)
                self?.page = (data != nil ? 1 : self?.page ?? 0)
            })
        }

        refreshControl.refreshingBottom = { [weak self] in
            self?.fetch(with: ((self?.page ?? 0) + 1), completion: { (data) in
                self?.refreshControl.refreshingBottomComplete(with: data)
                self?.page += (data != nil ? 1 : 0)
            })
        }
    }

    // MARK: - Data

    fileprivate func loadFirstData() {
        activityView.startAnimating()
        fetch(with: page, completion: { [weak self] (data) in
            self?.activityView.stopAnimating()
            /// чтобы при пустом экране не было кучи индикаторов если пользователь скроллит таблицу
            /// сконфигурим после получения первых данных
            self?.configureRefreshControl()
            self?.refreshControl.refreshingTopComplete(with: data)
        })
    }

    fileprivate func fetch(with page: Int, completion: ((_ data: [Any]?) -> Swift.Void)?) {
        fetchData?(page, completion)
    }
}

extension ListPaginationViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return calcDataSource.table(tableView, sectionSource: data, cellForIndexPath: indexPath)
    }
}

extension ListPaginationViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return calcDataSource.table(tableView, sectionSource: data, heightForRow: indexPath.row)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return calcDataSource.table(tableView, sectionSource: data, heightForRow: indexPath.row)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none

        if ReachabilityManager.shared.isNetworkAvailable == true {
            refreshControl.refreshBottomIfNeeded(forRowAt: indexPath)
        }
    }
}

extension ListPaginationViewController {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        refreshControl.tableViewDidScroll(scrollView)
    }
}
