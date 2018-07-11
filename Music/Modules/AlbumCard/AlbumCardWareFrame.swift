//
//  AlbumCardWareFrame.swift
//  Music
//
//  Created by Aleksandr on 07.02.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

protocol AlbumCardWireFramePresentable: class {
    func createModule(with object: AnyObject) -> UIViewController
    func createModuleAlbum(with ident: String) -> UIViewController
    func createModuleCollection(with ident: String) -> UIViewController
    func createPresentModule(with view: CardViewPresentable) -> PresentViewController
}

class AlbumCardWireFrame: AlbumCardWireFramePresentable {

    func createModule(with object: AnyObject) -> UIViewController {
        let vc = createModule()
        vc.presenter!.object = object
        return vc
    }

    func createModuleAlbum(with ident: String) -> UIViewController {
        let vc = createModule()
        vc.presenter!.albumIdent = ident
        return vc
    }

    func createModuleCollection(with ident: String) -> UIViewController {
        let vc = createModule()
        vc.presenter!.collectionIdent = ident
        return vc
    }

    func createPresentModule(with view: CardViewPresentable) -> PresentViewController {
        let viewController: AlbumCardViewController = AlbumCardViewController.loadFromNib()
        let presenter = AlbumCardPresenter()

        presenter.view = viewController
        viewController.presenter = presenter

        let presentVC = PresentViewController()
        presentVC.cardView = view
        presentVC.detailVC = viewController
        presentVC.completionPresent = {
            if let view = view as? CollectionView {
                viewController.presenter!.object = view.object
                viewController.presenter!.fetch()
            }
        }

        //presentVC.isFullscreen = false

        return presentVC
    }

    func createModule() -> AlbumCardViewController {
        let viewController: AlbumCardViewController = AlbumCardViewController.loadFromNib()
        let presenter = AlbumCardPresenter()

        let headerView: AlbumCardHeaderView = AlbumCardHeaderView.loadFromNib()
        viewController.tableHeaderView = headerView

        presenter.view = viewController
        presenter.headerView = headerView

        viewController.presenter = presenter
        headerView.presenter = presenter

        return viewController
    }
}
