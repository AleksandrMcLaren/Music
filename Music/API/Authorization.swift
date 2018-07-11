//
//  FirebasePhoneAuth.swift
//  ARGame
//
//  Created by Aleksandr on 28.12.2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit

class Authorization {

    static let shared = Authorization()
    private init() {}

    /// Статус авторизации
    var status: Bool {
       // get {
//            let user = nil
//            let authorized = ((user == nil) ? false : true)
//            return authorized;

            return true
      //  }
    }

    /// Отправляет номер телефона, на этот номер приходит sms код
    func verifyPhoneNumber(_ phoneNumber: String, completion: ((_ verificationID: String?, _ error: Error?) -> Void)?) {

    }

    /// Авторизация
    func signIn(_ verificationID: String, _ verificationCode: String, completion: ((_ user: AnyObject?, _ error: Error?) -> Void)?) {

    }
}
