//
//  AuthPhoneIntercator.swift
//  ARGame
//
//  Created by Aleksandr on 23/11/2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit

protocol AuthPhoneInteractorUseCase: class {
    func verifyPhone(_ phoneNumber: String?)
}

class AuthPhoneInteractor: AuthPhoneInteractorUseCase {

    weak var output: AuthPhoneInteractorOutput!

    deinit {

    }

    func verifyPhone(_ phoneNumber: String?) {

        guard var phoneNumber = phoneNumber
            else {
                self.phoneVerifyError("alert_wrong".lcd)
                return
        }

        phoneNumber = "+" + phoneNumber

        Authorization.shared.verifyPhoneNumber(phoneNumber) { [weak self] (verificationID, error) in

            if let error = error {
                print(error.localizedDescription)
                self?.phoneVerifyError(error.localizedDescription)
            } else {
                if let verificationID = verificationID {
                    self?.phoneVerified(verificationID)
                } else {
                    self?.phoneVerifyError("alert_wrong".lcd)
                }
            }
        }
    }

    func phoneVerified(_ verificationID: String) {
        DispatchQueue.main.async {
            self.output.phoneVerified(verificationID)
        }
    }

    func phoneVerifyError(_ message: String) {
        DispatchQueue.main.async {
            self.output.phoneVerifyError(message)
        }
    }
}
