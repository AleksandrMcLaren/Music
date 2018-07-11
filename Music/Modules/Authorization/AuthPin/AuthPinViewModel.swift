//
//  AuthPinViewModel.swift
//  ARGame
//
//  Created by Aleksandr on 22.01.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation

protocol AuthPinViewModelPresentation: class {
    var refreshing: ((_ value: Bool) -> Void)? { get set }
    var completion: ((_ user: AnyObject) -> Void)? { get set }
    var signInError: ((_ message: String?) -> Void)? { get set }

    func signIn(_ verificationID: String?, _ verificationCode: String?)
}

class AuthPinViewModel: AuthPinViewModelPresentation {

    var refreshing: ((Bool) -> Void)?
    var completion: ((AnyObject) -> Void)?
    var signInError: ((String?) -> Void)?

    func signIn(_ verificationID: String?, _ verificationCode: String?) {

        if checkCorrectData(verificationID, verificationCode) == false {
            return
        }

        refresh(true)

        Authorization.shared.signIn(verificationID!, verificationCode!) { [weak self] (user, error) in
            self?.refresh(false)

            if let error = error {
                print(error.localizedDescription)
                self?.signError(error.localizedDescription)
            } else {
                if let user = user {
                    self?.signInUser(user)
                } else {
                    self?.signError("alert_wrong".lcd)
                }
            }
        }
    }

    func checkCorrectData(_ verificationID: String?, _ verificationCode: String?) -> Bool {

        if let v = verificationID, let c = verificationCode {

            if v.isEmpty || c.isEmpty {
                self.signError("alert_wrong".lcd)
                return false
            }

            return true

        } else {
            return false
        }
    }

    func refresh(_ value: Bool) {
        DispatchQueue.main.async {
            self.refreshing?(value)
        }
    }

    func signInUser(_ user: AnyObject) {
        DispatchQueue.main.async {
            self.completion?(user)
        }
    }

    func signError(_ message: String) {
        DispatchQueue.main.async {
            self.signInError?(message)
        }
    }
}
