//
//  TrackSource.swift
//  Music
//
//  Created by Aleksandr on 24.04.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

class TrackSource: RowSource {

    // MARK: - Configure cell

    public var data: Any?
    public var parentData: AnyObject?
    public var height: CGFloat? = 78.0
    public var heightScale: CGFloat = 1

    public func configureCell(_ cell: TrackViewCell) {
        cell.object = data
        cell.tapped = { [unowned self] in
            if let obj = self.parentData, let track = self.data as? DBTrack {
                player.playContent = PlayContent(with: obj, playTrack: track)
                player.play()
            }
        }
    }

    // MARK: - Create source

    func tracks(with objects: [Any], parentObject: Any) -> [TrackSource] {
        var list = [TrackSource]()

        for obj in objects {
            let source = track(with: obj, parentObject: parentObject)
            list.append(source)
        }

        return list
    }

    func track(with object: Any, parentObject: Any) -> TrackSource {
        let source = TrackSource()
        source.data = object
        source.parentData = parentObject as AnyObject
        return source
    }
}
