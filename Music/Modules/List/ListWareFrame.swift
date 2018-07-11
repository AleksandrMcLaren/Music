//
//  ListWareFrame.swift
//  Music
//
//  Created by Aleksandr on 05.04.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

protocol ListWareFramePresentable: class {
    func createModuleCollection(with ident: String) -> UIViewController
}

class ListWareFrame: ListWareFramePresentable {

    func createModuleCollection(with ident: String) -> UIViewController {
        let vc = createModule()
        vc.title = "title_collections".lcd
        vc.presenter!.objectIdent = ident
        return vc
    }

    func createModule() -> ListViewController {

        let viewController: ListViewController = ListViewController.loadFromNib()
        let presenter = ListPresenter()

        presenter.view = viewController
        viewController.presenter = presenter

        return viewController
    }
}
