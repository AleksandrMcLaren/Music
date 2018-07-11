//
//  AppDelegate.swift
//  Music
//
//  Created by Aleksandr on 23.01.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinatorInterface?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        appearance()
        initializeUserInterface()

        return true
    }

    override init() {
        super.init()
        UIView.classInit
        UIViewController.classInit
    }
    
    func initializeUserInterface() {

        appCoordinator = AppCoordinator.shared

        window = UIWindow.init(frame: UIScreen.main.bounds)
        window!.rootViewController = appCoordinator!.navController
        window!.makeKeyAndVisible()

        appCoordinator!.start()
    }

    func appearance() {
        UINavigationBar.appearance().backgroundColor = .white
        UINavigationBar.appearance().largeTitleTextAttributes =
            [NSAttributedStringKey.font: Font.shared.lightFont(ofSize: 32)]
        UINavigationBar.appearance().titleTextAttributes =
            [NSAttributedStringKey.font: Font.shared.lightFont(ofSize: 22)]
    }
}
