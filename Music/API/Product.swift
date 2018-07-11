//
//  Product.swift
//  Music
//
//  Created by Aleksandr on 28.02.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation

class Product {

    deinit {
      
    }

    func getSourceAlbumNews(page: Int, completion: (([AlbumSource]?) -> Swift.Void)?) {
        getNews(page: page) { (data) in
            DispatchQueue.global(qos: .default).async {
                var source: [AlbumSource]?

                if let data = data {
                    source = AlbumSource().albums(with: data)
                }

                DispatchQueue.main.async {
                    completion?(source)
                }
            }
        }
    }

    func getNews(page: Int, completion: (([DBAlbum]?) -> Swift.Void)?) {

        DispatchQueue.global(qos: .default).async {

            func asyncCompletion(_ obj: [DBAlbum]?) {
                DispatchQueue.main.async {
                    completion?(obj)
                }
            }

            var params = [String: String]()
            params["method"] = "product.getNews"
            params["limit"] = "30"
            params["page"] = String(page)

            API.shared.get(params) { (json) in
                guard let json = json else {
                    asyncCompletion(nil)
                    return
                }

                self.createAlbums(with: json, completion: { (object) in
                    asyncCompletion(object)
                })
            }
        }
    }
}

extension Product {

    func createAlbums(with json: [String: Any], completion: (([DBAlbum]?) -> Swift.Void)?) {

        var albums = [DBAlbum]()

        if let responceDict = json["response"] as? [String: Any],
            let albumIds = responceDict["albums"] as? [String], albumIds.count > 0,
            let collectionDict = json["collection"] as? [String: Any],
            let albumsDict = collectionDict["album"] as? [String: Any] {

            let peoplesDict = collectionDict["people"] as? [String: Any]

            for id in albumIds {
                if let albumDict = albumsDict[id] as? [String: Any],
                    let album = DBAlbum.objectFromDict(albumDict) {
                    albums.append(album)
                    album.addPeoples(peoplesDict)
                }
            }
        }

        completion?(albums.count > 0 ? albums : nil)
    }
}
