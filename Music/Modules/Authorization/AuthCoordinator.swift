//
//  AuthCoordinator.swift
//  ARGame
//
//  Created by Aleksandr on 21/11/2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit

protocol AuthCoordinatorPresentation: class {
    init(navigationController: UITabBarController)
    func start(animated: Bool)

    var completion: ((_ user: AnyObject) -> Void)? { get set }
}

class AuthCoordinator: AuthCoordinatorPresentation {

    internal var completion: ((_ user: AnyObject) -> Void)?

    fileprivate var appNavController: UITabBarController!
    fileprivate var authNavController: UINavigationController?

    convenience required init(navigationController: UITabBarController) {
        self.init()
        self.appNavController = navigationController
    }

    deinit {

    }

    func start(animated: Bool) {
        openPhoneViewController(animated: animated)
    }

    fileprivate func openPhoneViewController(animated: Bool) {

        /// сделать как в openPinViewController

        let authPhone = AuthPhoneWireFrame() as AuthPhoneWireFramePresentation
        let vc = authPhone.createModule()
        authNavController = UINavigationController.init(rootViewController: vc)
        appNavController.present(authNavController!, animated: animated, completion: nil)

        authPhone.completion = { [unowned self] (verificationID) -> Void in
            self.openPinViewController(verificationID)
        }
    }

    fileprivate func openPinViewController(_ verificationID: String) {

        let vc: AuthPinViewController = AuthPinViewController.loadFromNib()
        vc.verificationID = verificationID
        authNavController?.pushViewController(vc, animated: true)

        vc.completion = { [unowned self] (user) -> Void in
            self.appNavController.dismiss(animated: true, completion: {
                self.completion?(user)
            })
        }
    }
}
