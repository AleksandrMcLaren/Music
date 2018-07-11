//
//  TabBarController.swift
//  ARGame
//
//  Created by Aleksandr on 22/11/2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit
import MessageKit

class TabBarController: UITabBarController {

    public var didSelect: ((_ viewController: UIViewController) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        configureControllers()
    }

    fileprivate func configureControllers () {

        
//        let album = AlbumCardWireFrame() as AlbumCardWireFramePresentable
//        let albumVC = album.createModuleAlbum(with: "247779")
//        albumVC.tabBarItem.title = "tab_item_album".lcd
//        //albumVC.tabBarItem.image = UIImage(named: "tab_bar_menu")

      //  let albumsVC: AlbumListNewsViewController = AlbumListNewsViewController.loadFromNib()
        let catalogVC: CatalogViewController = CatalogViewController.loadFromNib()
        let catalog = UINavigationController.init(rootViewController: catalogVC)
        catalog.tabBarItem.title = "tab_item_catalog".lcd

        let recomVC: RecomViewController = RecomViewController.loadFromNib()
        let recom = UINavigationController.init(rootViewController: recomVC)
        recom.tabBarItem.title = "tab_item_recom".lcd

        //let chatVC = MessagesViewController.init()

        viewControllers = [catalog, recom]
    }
}

extension TabBarController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        didSelect?(viewController)
    }
}
