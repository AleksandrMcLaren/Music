//
//  ListPresenter.swift
//  Music
//
//  Created by Aleksandr on 05.04.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation

protocol ListPresentable: class {
    var objectIdent: String? { get set }
    func fetch()
}

class ListPresenter: ListPresentable {

    weak var view: ListViewPresentable?

    // MARK: ListPresentable
    var objectIdent: String?

    func fetch() {
        if let ident = objectIdent {
            Shopwindow().getSourceCollectionGroup(with: ident, completion: { [weak self] (source) in
                self?.view?.fetchCompletion(source)
            })
        }
    }
}
