//
//  AppCoordinator.swift
//  ARGame
//
//  Created by Aleksandr on 21/11/2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit

protocol AppCoordinatorInterface: class {

    /// Навигационный контроллер
    var navController: TabBarController! { get set }

    /// Запускает жизненный цикл приложения
    func start()
    /// Запускает авторизацию
    func logout()

    /// Открывает экран Новинки
    func openAlbumListNews()
    /// Открывает карточки Альбома или Подборки
    func pushCard(with object: AnyObject)
    func presentCard(_ card: CardViewPresentable)
    /// Открывает карточки по ident из пушей
    func pushCardAlbum(with ident: String)
    func pushCardCollection(with ident: String)
    /// Открывает список подборок
    func pushListCollection(with ident: String)
    /// Открывает список треков
    func pushListTracks(with recommendGroup: DBRecommendationGroup)
}

/** Координатор жизненного цикла приложения */
class AppCoordinator: Coordinator {

    internal var navController: TabBarController!
    internal var childCoordinators: [AnyObject] = []
    fileprivate var tabBarController: TabBarController!
    fileprivate let reachabilityManager = ReachabilityManager.shared

    static let shared: AppCoordinatorInterface = AppCoordinator()
    private init() {
        configureAppUIContent()
        reachabilityManager.startNotifier()
        addMiniPlayerNeedsOpenNotification()
    }

    /** Создает контент приложения.
        В TabBarController, если нужна навигация внутри TabBarItem, TabBarItem запускается со своим навигационным контроллером */
    fileprivate func configureAppUIContent() {
        configureTabBarController()
        navController = tabBarController
       // navController = TabBarController() //UINavigationController.init(rootViewController: tabBarController)
       // navController.navigationBar.isHidden = true
    }

    fileprivate func configureTabBarController() {
        tabBarController = TabBarController()
        tabBarController.didSelect = { [unowned self] (contr) -> Void in

        }
    }

    fileprivate lazy var miniPlayer: MiniPlayerPresentable = {
        let miniPlayer: MiniPlayer = MiniPlayer.loadFromNib()
        return miniPlayer
    }()
}

// MARK: - AppCoordinatorInterface

extension AppCoordinator: AppCoordinatorInterface {

    func start() {

        return

        if Authorization.shared.status == false {
            DispatchQueue.main.async {
                if self.canOpenAuth() {
                    self.openAuth(animated: false)
                }
            }
        }

        self.configureAuth()
    }

    func logout() {
        DispatchQueue.main.async {
            if self.canOpenAuth() {
                self.openAuth(animated: true)
            }
        }
    }

    func openAlbumListNews() {
        if let contr = currentController() {
            let vc = ListPaginationWareFrame().createModuleAlbumNews()
            contr.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func pushCard(with object: AnyObject) {
        if let contr = currentController() {
            let cardWareFrame = AlbumCardWireFrame() as AlbumCardWireFramePresentable
            let vc = cardWareFrame.createModule(with: object)
            contr.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func pushCardAlbum(with ident: String) {
        if let contr = currentController() {
            let cardWareFrame = AlbumCardWireFrame() as AlbumCardWireFramePresentable
            let vc = cardWareFrame.createModuleAlbum(with: ident)
            contr.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func pushCardCollection(with ident: String) {
        if let contr = currentController() {
            let cardWareFrame = AlbumCardWireFrame() as AlbumCardWireFramePresentable
            let vc = cardWareFrame.createModuleCollection(with: ident)
            contr.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func pushListCollection(with ident: String) {
        if let contr = currentController() {
            let list = ListWareFrame() as ListWareFramePresentable
            let vc = list.createModuleCollection(with: ident)
            contr.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func pushListTracks(with recommendGroup: DBRecommendationGroup) {
        if let contr = currentController() {
            let vc = ListPaginationWareFrame().createModuleTracks(with: recommendGroup)
            contr.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func presentCard(_ card: CardViewPresentable) {
        if let contr = currentController() {
            // Вариант present() with modalPresentationStyle = .currentContext не работает если с открытой карточкой переключить вкладку в таб бар,
            // вернутся и свернуть карточку; будет черный экран
            // Поэтому сделаем так
            let cardWareFrame = AlbumCardWireFrame() as AlbumCardWireFramePresentable
            let presentVC = cardWareFrame.createPresentModule(with: card)
            presentVC.superVC = contr
            presentVC.cardOriginalFrame = card.convertRect(to: contr.view)
            contr.addChildViewController(presentVC)
            contr.view.addSubview(presentVC.view)
        }
    }

    fileprivate func currentController() -> UIViewController? {
        let index = tabBarController.selectedIndex

        if let viewControllers = tabBarController.viewControllers,
            let curTabBarContr = viewControllers[index] as? UINavigationController,
            let curContrInTabBar = curTabBarContr.viewControllers.last {
            return curContrInTabBar
        }

        return nil
    }
}

extension AppCoordinator {

    /// Запускает кейс авторизации
    fileprivate func openAuth(animated: Bool) {
        let authCoordinator: AuthCoordinatorPresentation = AuthCoordinator(navigationController: navController)
        authCoordinator.completion = { [unowned self, unowned authCoordinator] (user) -> Void in
            self.removeChildCoordinator(authCoordinator)
        }

        authCoordinator.start(animated: animated)
        addChildCoordinator(authCoordinator)
    }

    fileprivate func configureAuth() {
        /// подпишемся на изменение статуса авторизации
        API.shared.authorizationDidChange = { [unowned self] (auth) in
            if auth == false {
                self.logout()
            }
        }
    }

    /// Проверка на возможность запуска авторизации
    fileprivate func canOpenAuth() -> Bool {
        return !(childCoordinators.last is AuthCoordinatorPresentation)
    }
}

extension AppCoordinator: MiniPlayerNotification {

    func miniPlayerNeedsOpen() {
        let tabBarFrame = tabBarController.tabBar.frame
        let width = tabBarFrame.width
        let height = tabBarFrame.height
        let y = tabBarFrame.origin.y - height
        let startFrame = CGRect(x: 0, y: tabBarFrame.origin.y, width: width, height: 0)
        let endFrame = CGRect(x: 0, y: y, width: width, height: height)

        miniPlayer.show(in: navController.view, startFrame: startFrame, endFrame: endFrame)
    }

    func miniPlayerLayout() {}
}
