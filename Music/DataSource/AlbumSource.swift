//
//  AlbumSource.swift
//  Music
//
//  Created by Aleksandr on 23.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

class AlbumSource: RowSource {

    // MARK: - Configure cell

    var data: DBAlbum?
    public var height: CGFloat?
    public var heightScale: CGFloat = 0.5

    func configureCell(_ cell: AlbumViewCell) {
        cell.object = data
    }

    // MARK: - Create source

    func albums(with objects: [Any]) -> [AlbumSource] {
        var list = [AlbumSource]()

        objects.forEach { (obj) in
            let source = album(with: obj)
            list.append(source)
        }

        return list
    }

    func album(with object: Any) -> AlbumSource {
        let source = AlbumSource()
        source.data = object as? DBAlbum
        return source
    }
}
