//
//  ListViewController.swift
//  Music
//
//  Created by Aleksandr on 05.04.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

protocol ListViewPresentable: class {
    func fetchCompletion(_ source: TableDataSource?)
}

class ListViewController: UIViewController, ListViewPresentable {

    @IBOutlet weak var tableView: TableView!
    @IBOutlet weak var activityView: ActivityIndicatorView!

    var presenter: ListPresentable?

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

    deinit {
      print(" ")
    }

    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        activityView.startAnimating()
        presenter?.fetch()
    }

    override func viewColors() {
        view.backgroundColor = cBackground
        tableView.backgroundColor = cBackground
    }

    // MARK: - Data

    func fetchCompletion(_ source: TableDataSource?) {
        activityView.stopAnimating()
        dataSource = source
    }
}
