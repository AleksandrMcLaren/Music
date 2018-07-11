//
//  AuthPhoneFacade.swift
//  ARGame
//
//  Created by Aleksandr on 23/11/2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit

protocol AuthPhoneWireFramePresentation: class {
    func createModule() -> UIViewController
    var completion: ((_ verificationID: String) -> Void)? { get set }
}

protocol AuthPhonePresenterOutput: class {
    func presenterCompletion(_ verificationID: String)
}

class AuthPhoneWireFrame: AuthPhoneWireFramePresentation {

    var completion: ((String) -> Void)?

    deinit {

    }

    func createModule() -> UIViewController {

        let viewController: AuthPhoneViewController = AuthPhoneViewController.loadFromNib()
        let presenter = AuthPhonePresenter()
        let interactor = AuthPhoneInteractor()

        presenter.view = viewController
        presenter.interactor = interactor
        presenter.wareFrame = self

        viewController.presenter = presenter

        interactor.output = presenter

        return viewController
    }
}

extension AuthPhoneWireFrame: AuthPhonePresenterOutput {

    func presenterCompletion(_ verificationID: String) {
        completion?(verificationID)
    }
}
