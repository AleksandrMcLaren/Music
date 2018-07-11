//
//  CatalogViewController.swift
//  Music
//
//  Created by Aleksandr on 21.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

class CatalogViewController: UIViewController {

    @IBOutlet weak var tableView: TableView!
    @IBOutlet weak var activityView: ActivityIndicatorView!

    fileprivate var dataSource: TableDataSource? {
        didSet{
            guard dataSource != nil else {
                return
            }

            tableView.delegate = dataSource
            tableView.dataSource = dataSource
            tableView.reloadData()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        loadFirstData()
    }

    // MARK: - Configure

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewColors() {
        view.backgroundColor = cBackground
        tableView.backgroundColor = cBackground
    }

    fileprivate func configureViews() {
        title = "title_catalog".lcd
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    fileprivate func configureRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }

    // MARK: - Data

    fileprivate func loadFirstData() {
        activityView.startAnimating()
        fetchData(completion: { [weak self] (source) in
            self?.activityView.stopAnimating()
            self?.configureRefreshControl()
            self?.dataSource = source
        })
    }

    @objc fileprivate func refreshData() {
        fetchData(completion: { [weak self] (source) in
            self?.tableView.refreshControl?.endRefreshing()
            self?.dataSource = source
        })
    }

    fileprivate func fetchData(completion: ((_ source: TableDataSource) -> Swift.Void)?) {
        Shopwindow().getSourceCollectionGroups { (source) in
            completion?(source)
        }
    }
}
