//
//  Selection.swift
//  Music
//
//  Created by Aleksandr on 21.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation

// MARK: Запросы

class Shopwindow {

    // MARK: Catalog

    func getSourceCollectionGroups(completion: ((TableDataSource) -> Swift.Void)?) {

        let tableSource = TableDataSource()
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        Product().getNews(page: 1) { (data) in
            DispatchQueue.global(qos: .default).async {
                if let albums = data, !albums.isEmpty {
                    let section = self.sourceSectionNews(with: albums)
                    tableSource.sections.insert(section, at: 0)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.enter()
        getCollectionGroups { (data) in
            DispatchQueue.global(qos: .default).async {
                if let groups = data {
                    let sections = self.sourceSectionCollection(with: groups)
                    tableSource.sections.append(contentsOf: sections)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion?(tableSource)
        }
    }

    func getCollectionGroups(completion: (([DBCollectionGroup]?) -> Swift.Void)?) {

        DispatchQueue.global(qos: .default).async {

            func asyncCompletion(_ obj: [DBCollectionGroup]?) {
                DispatchQueue.main.async {
                    completion?(obj)
                }
            }

            var params = [String: String]()
            params["method"] = "shopwindow.GetSelectionGroup"

            API.shared.get(params) { (json) in
                guard let json = json else {
                    asyncCompletion(nil)
                    return
                }

                self.createCollectionGroups(with: json, completion: { (object) in
                    asyncCompletion(object)
                })
            }
        }
    }

    func getSourceCollectionGroup(with ident: String, completion: ((TableDataSource?) -> Swift.Void)?) {
        getCollectionGroup(with: ident) { (group) in

            DispatchQueue.global(qos: .default).async {
                var tableSource: TableDataSource?

                if let group = group, let collections = group.collections?.array as? [DBCollection], !collections.isEmpty {
                    tableSource = TableDataSource()

                    let section = TableDataSourceSection()
                    section.source = CollectionSource().collections(with: collections)
                    tableSource!.sections.append(section)
                }

                DispatchQueue.main.async {
                    completion?(tableSource)
                }
            }
        }
    }

    func getCollectionGroup(with ident: String, completion: ((DBCollectionGroup?) -> Swift.Void)?) {

        DispatchQueue.global(qos: .default).async {

            func asyncCompletion(_ obj: DBCollectionGroup?) {
                DispatchQueue.main.async {
                    completion?(obj)
                }
            }

            var params = [String: String]()
            params["method"] = "shopwindow.GetSelectionByGroup"
            params["groupId"] = ident

            API.shared.get(params) { (json) in
                guard let json = json else {
                    asyncCompletion(nil)
                    return
                }

                self.createCollectionGroup(with: json, completion: { (object) in
                    asyncCompletion(object)
                })
            }
        }
    }

    // MARK: Recommendation

    func getSourceRecommendation(completion: ((TableDataSource?) -> Swift.Void)?) {
        getRecommendation() { (groups) in
            DispatchQueue.global(qos: .default).async {
                var tableSource: TableDataSource?

                if let groups = groups {
                    tableSource = TableDataSource()
                    tableSource!.sections = self.sourceSectionRecommend(with: groups)
                }

                DispatchQueue.main.async {
                    completion?(tableSource)
                }
            }
        }
    }

    func getRecommendation(completion: (([DBRecommendationGroup]?) -> Swift.Void)?) {

        DispatchQueue.global(qos: .default).async {

            func asyncCompletion(_ obj: [DBRecommendationGroup]?) {
                DispatchQueue.main.async {
                    completion?(obj)
                }
            }

            var params = [String: String]()
            params["method"] = "showcase.recommend"

            API.shared.get(params) { (json) in
                guard let json = json else {
                    asyncCompletion(nil)
                    return
                }

                self.createRecommendGroups(with: json, completion: { (object) in
                    asyncCompletion(object)
                })
            }
        }
    }

    func getSourceRecommendTracks(page: Int, group: DBRecommendationGroup, completion: (([TrackSource]?) -> Swift.Void)?) {
        getRecommendTracks(page: page, group: group) { (tracks) in
            DispatchQueue.global(qos: .default).async {
                var source: [TrackSource]?

                if let tracks = tracks {
                    source = TrackSource().tracks(with: tracks, parentObject: tracks)
                }

                DispatchQueue.main.async {
                    completion?(source)
                }
            }
        }
    }

    func getRecommendTracks(page: Int, group: DBRecommendationGroup, completion: (([DBTrack]?) -> Swift.Void)?) {

        DispatchQueue.global(qos: .default).async {

            func asyncCompletion(_ obj: [DBTrack]?) {
                DispatchQueue.main.async {
                    completion?(obj)
                }
            }

            var params = [String: String]()
            params["method"] = "showcase.recommend"
            params["slug"] = group.slug ?? ""
            params["page"] = String(page)
            params["categoryId"] = group.categoryId ?? ""

            API.shared.get(params) { (json) in
                guard let json = json else {
                    asyncCompletion(nil)
                    return
                }

                self.createRecommendTracks(with: json, completion: { (object) in
                    asyncCompletion(object)
                })
            }
        }
    }
}

// MARK: Парсинг

extension Shopwindow {

    func createCollectionGroups(with json: [String: Any], completion: (([DBCollectionGroup]) -> Swift.Void)?) {
        var groups = [DBCollectionGroup]()
        let curGroups = DBCollectionGroup.getAll()

        if let responce = json["response"] as? [String: Any],
            let shopwindow = responce["shopwindow"] as? [[String: Any]],
            let collection = json["collection"] as? [String: Any],
            let collections = collection["selection"] as? [String: Any] {
            
            for (index, groupDict) in shopwindow.enumerated() {
                if let group = DBCollectionGroup.objectFromDict(groupDict) {
                    group.setOrder(Int32(index))
                    group.addCollections(collections)
                    group.addTrackDataCollections()
                    groups.append(group)
                }
            }
        }

        /// удалим из БД старые группы
        if groups.count > 0, let curGroups = curGroups as? [DBCollectionGroup] {
            let oldGroups = Array(Set(curGroups).subtracting(groups))

            if oldGroups.count > 0 {
                DBCollectionGroup.deleteObjects(oldGroups)
            }
        }

       // DataSource.shared.context.needsSave()
        
        completion?(groups)
    }

    func createCollectionGroup(with json: [String: Any], completion: ((DBCollectionGroup?) -> Swift.Void)?) {

        var group: DBCollectionGroup?

        if let collection = json["collection"] as? [String: Any],
            let groupDict = collection["group"] as? [String: Any] {
            group = DBCollectionGroup.objectFromDict(groupDict)

            if let group = group,
                let responce = json["response"] as? [String: Any],
                let ids = responce["selectionIds"] as? [Any],
                let collections = collection["selection"] as? [String: Any] {
                group.setCollectionIds(ids)
                group.addCollections(collections)
            }
        }

        completion?(group)
    }

    func createRecommendGroups(with json: [String: Any], completion: (([DBRecommendationGroup]) -> Swift.Void)?) {
        var groups = [DBRecommendationGroup]()
        let curGroups = DBRecommendationGroup.getAll()

        if let responce = json["response"] as? [String: Any],
            let showcaseIds = responce["showcaseIds"] as? [String],
            let collection = json["collection"] as? [String: Any],
            let showcase = collection["showcase"] as? [String: Any] {

            let tracksDict = collection["track"] as? [String: Any]
            let peoplesDict = collection["people"] as? [String: Any]
            let categoryDict = collection["category"] as? [String: Any]
            let albumDict = collection["album"] as? [String: Any]

            for (index, id) in showcaseIds.enumerated() {
                if let groupDict = showcase[id] as? [String: Any],
                let group = DBRecommendationGroup.objectFromDict(groupDict) {
                    group.setOrder(Int32(index))

                    /// group => albums
                    if let albumIds = groupDict["albumIds"] as? [Any] {
                        group.setAlbumIds(albumIds)
                        group.addAlbums(albumDict)

                        if let albums = group.albums?.array as? [DBAlbum] {
                            for album in albums {
                                /// group => albums => peoples
                                album.addPeoples(peoplesDict)
                                album.createPeopleList()

                                /// group => albums => tracks
                                album.addTracks(tracksDict)

                                if let tracks = album.tracks?.array as? [DBTrack] {
                                    for track in tracks {
                                        /// group => albums => tracks => peoples
                                        track.addPeoples(peoplesDict)
                                        track.createPeopleList()
                                    }
                                }
                            }
                        }
                    }

                    /// group => peoples
                    group.addPeoples(peoplesDict)

                    if let peoples = group.peoples?.array as? [DBPeople] {
                        for people in peoples {
                            /// group => peoples => tracks
                            people.addTracks(tracksDict)

                            if let categoryDict = categoryDict {
                                /// group => peoples => category
                                people.addCategory(categoryDict)
                            }
                        }
                    }

                    /// group => tracks
                    if let tracksIds = groupDict["trackIds"] as? [Any] {
                        group.setTrackIds(tracksIds)
                        group.addTracks(tracksDict)

                        if let tracks = group.tracks?.array as? [DBTrack] {
                            for track in tracks {
                                /// group => tracks => peoples
                                track.addPeoples(peoplesDict)
                                track.createPeopleList()
                                /// group => tracks => album
                                track.addAlbum(with: albumDict)
                            }
                        }
                    }

                    groups.append(group)
                }
            }
        }

        /// удалим из БД старые группы
        if groups.count > 0, let curGroups = curGroups as? [DBRecommendationGroup] {
            let oldGroups = Array(Set(curGroups).subtracting(groups))

            if oldGroups.count > 0 {
                DBCollectionGroup.deleteObjects(oldGroups)
            }
        }

        // DataSource.shared.context.needsSave()

        completion?(groups)
    }

    func createRecommendTracks(with json: [String: Any], completion: (([DBTrack]) -> Swift.Void)?) {
        var tracks = [DBTrack]()

        if let collection = json["collection"] as? [String: Any],
            let showcaseDict = collection["showcase"] as? [String: Any],
            let showcase = showcaseDict[showcaseDict.keys.first ?? ""] as? [String: Any],
            let trackIds = showcase["trackIds"] as? [String],
            let tracksDict = collection["track"] as? [String: Any] {

            let peoplesDict = collection["people"] as? [String: Any]

            for id in trackIds {
                if let objectDict = tracksDict[id] as? [String: Any],
                    let track = DBTrack.objectFromDict(objectDict) {
                    track.addPeoples(peoplesDict)
                    track.createPeopleList()
                    tracks.append(track)
                }
            }
        }

        completion?(tracks)
    }
}

// MARK: Сборка источников для экранов

enum ShopwindowType: String {
    case selection_carousel
    case selection_day_album
    case selection_slider
    case selection_vertical
}

extension Shopwindow {

    func sourceSectionNews(with albums: [DBAlbum]) -> TableDataSourceSection {
        let section = TableDataSourceSection()
        section.title = "title_album_news".lcd
        section.titleAction = {
            AppCoordinator.shared.openAlbumListNews()
        }

        let source = SliderSource().slider(with: albums)
        source.type = .album
        source.heightScale = 0.5
        section.source = [source]
        return section
    }

    func sourceSectionCollection(with groups: [DBCollectionGroup]) -> [TableDataSourceSection] {
        var sections = [TableDataSourceSection]()

        for group in groups {

            guard let collections = group.collections, collections.count > 0 else {
                continue
            }

            let section = TableDataSourceSection()
            section.title = group.name
            section.titleAction = {
                if let ident = group.id {
                    AppCoordinator.shared.pushListCollection(with: ident)
                }
            }

            sections.append(section)

            if group.type == ShopwindowType.selection_carousel.rawValue {
                let source = SliderSource().slider(with: collections.array)
                source.type = .collection
                source.heightScale = 0.68
                section.source = [source]
            } else if group.type == ShopwindowType.selection_day_album.rawValue {
                let source = CollectionSource().collection(with: collections[0], square: true)
                source.heightScale = 0.68
                section.source = [source]
                section.titleAction = nil
            } else if group.type == ShopwindowType.selection_slider.rawValue {
                let source = SliderSource().slider(with: collections.array)
                source.type = .collectionSquare
                section.source = [source]
            } else if group.type ==  ShopwindowType.selection_vertical.rawValue {
                let sources = CollectionSource().collections(with: collections.array)
                section.source = sources
            }
        }

        return sections
    }

    func sourceSectionRecommend(with groups: [DBRecommendationGroup]) -> [TableDataSourceSection] {
        var sections = [TableDataSourceSection]()

        for group in groups {

            let section = TableDataSourceSection()
            section.title = group.title
            sections.append(section)

            // отступ в Рекоммендациях после каждой секции. У вьюх треков оступ меньше чем у вьюх подборок
            addEmptySection(to: &sections)

            if group.slug == "genre-new-tracks" ||
                group.slug == "now-listening" ||
                group.slug == "listen-tracks" {

                section.titleAction = {
                    AppCoordinator.shared.pushListTracks(with: group)
                }

                if let objects = group.tracks?.array {
                    let source = TrackSource().tracks(with: objects, parentObject: objects)
                    section.source = source
                }
            } else if group.slug == "popular-albums" {
                if let albums = group.albums?.array {
                    let source = SliderSource().slider(with: albums)
                    source.type = .albumSquareCarousel
                    section.source = [source]

                    if let album = albums.first as? DBAlbum, let tracks = album.tracks {
                        let partTracks = Array(tracks.prefix(3))
                        let tracksSource = TrackSource().tracks(with: partTracks, parentObject: partTracks)
                        section.source!.append(contentsOf: tracksSource)
                    }
                }
            } else if group.slug == "selected-genre" {
                if let albums = group.albums?.array {
                    let source = SliderSource().slider(with: albums)
                    source.type = .albumSquare
                    source.heightScale = 0.5
                    section.source = [source]

                    if let tracks = group.tracks?.array as? [DBTrack] {
                        let tracksSource = TrackSource().tracks(with: tracks, parentObject: tracks)
                        section.source!.append(contentsOf: tracksSource)
                    }
                }
            }
        }

        return sections
    }

    func addEmptySection(to sections: inout [TableDataSourceSection]) {
        let emptySection = TableDataSourceSection()
        emptySection.source = [EmptySource()]
        sections.append(emptySection)
    }
}
