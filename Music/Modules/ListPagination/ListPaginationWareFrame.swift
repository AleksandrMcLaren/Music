//
//  ListPaginationWareFrame.swift
//  Music
//
//  Created by Aleksandr on 27.04.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

protocol ListPaginationWareFramePresentable: class {
    func createModuleAlbumNews() -> UIViewController
    func createModuleTracks(with recommendGroup: DBRecommendationGroup) -> UIViewController
}

class ListPaginationWareFrame: ListPaginationWareFramePresentable {

    func createModuleAlbumNews() -> UIViewController {
        let vc = ListPaginationViewController()
        vc.title = "title_album_news".lcd
        vc.fetchData = { (page, completion) in
            Product().getSourceAlbumNews(page: page) { (source) in
                completion?(source)
            }
        }

        return vc
    }

    func createModuleTracks(with recommendGroup: DBRecommendationGroup) -> UIViewController {
        let vc = ListPaginationViewController()
        vc.title = recommendGroup.title
        vc.backButtonTitle = ""
        vc.fetchData = { (page, completion) in
            Shopwindow().getSourceRecommendTracks(page: page, group: recommendGroup, completion: { (source) in
                completion?(source)
            })
        }

        return vc
    }
}
