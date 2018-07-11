//
//  API.swift
//  Music
//
//  Created by Aleksandr on 23.01.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation
import UIKit

class API {

    /// Подписка на изменение статуса авторизации
    public var authorizationDidChange: ((_ status: Bool) -> Void)?

    fileprivate lazy var url: String = {
        let url = "http://"
        //let url = "http://"
        return url
    }()

    fileprivate lazy var defaultParams: [String: String] = {
        let params = ["device": "ios",
                      "app": "",
                      "version": ""] //Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
        return params
    }()

    fileprivate lazy var methodUrl: String = {
        let methodUrl = url + "/api/"
        return methodUrl
    }()

    fileprivate var network = MLNetwork()

    public static let shared = API()
    private init() {}

    fileprivate func allParameters(add params: [String: String]?) -> [String: String] {

        var allParams = defaultParams
        allParams["token"] = ""
        allParams["language"] = "ru"

        if let addParams = params {
            allParams.merge(addParams) { (current, _) in current }
        }

        return allParams
    }

    fileprivate func isBackendError(_ json: [String: Any]) -> Bool {

        if let error = json["error"] as? [String: Any] {
            if let code = error["code"] as? Int, code == -2 || code == -10 {
                /// -2 Не авторизован
                /// -10 Номер не принадлежит Activ или Kcell
                DispatchQueue.main.async {
                    self.authorizationDidChange?(false)
                }
                return true
            }
        }

        return false
    }
}

extension API {

    public func get(_ params: [String: String]?, completion: (([String: Any]?) -> Swift.Void)?) {

        let allParams = allParameters(add: params)
        network.get(methodUrl, allParams) { (data, response, error) in

            if error == nil {
                do {
                    if let data = data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if self.isBackendError(json) == false {
                            completion?(json)
                            return
                        }
                    }
                } catch {
                    print("Error. \(String(describing: type(of: self))). \(#function): \(error)")
                }
            } else {
                print("Error. \(String(describing: type(of: self))). \(#function): \(String(describing: error))")
            }

            completion?(nil)
        }
    }
}

extension API {

    static let screenScale: CGFloat = UIScreen.main.scale

    public func imageUrl(with string: String?, width: CGFloat, height: CGFloat) -> URL? {
        var url: URL?

        guard let string = string else {
            return url
        }

        let scaleWidth = Int(width * API.screenScale)
        let scaleHeight = Int(height * API.screenScale)
        let paramsString = String(format: "crop/\(scaleWidth)x\(scaleHeight)/\(string)")

        var signString = String(paramsString)
        signString += ""
        signString = signString.utf8.md5.rawValue

        let fullString = String(format: "http://\(signString)/\(paramsString)")
        url = URL(string: fullString)

        return url
    }
}
