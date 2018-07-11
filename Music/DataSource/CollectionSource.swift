//
//  CollectionSource.swift
//  Music
//
//  Created by Aleksandr on 30.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

class CollectionSource: RowSource {

    // MARK: - Configure cell
    
    var data: DBCollection?
    var isSquare = false
    public var height: CGFloat?
    public var heightScale: CGFloat = 0.5

    func configureCell(_ cell: CollectionViewCell) {
        cell.isSquare = isSquare
        cell.object = data
    }

    // MARK: - Create source

    func collections(with objects: [Any]) -> [CollectionSource] {
        var list = [CollectionSource]()

        for obj in objects {
            let source = collection(with: obj, square: false)
            list.append(source)
        }

        return list
    }

    func collection(with object: Any, square: Bool) -> CollectionSource {
        let source = CollectionSource()
        source.data = object as? DBCollection
        source.isSquare = square
        return source
    }
}
