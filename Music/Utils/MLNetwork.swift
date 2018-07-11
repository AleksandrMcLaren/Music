//
//  MLNetwork.swift
//
//  Created by Aleksandr on 23.01.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation

class MLNetwork {

    fileprivate lazy var sessionConfiguration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        config.httpCookieAcceptPolicy = .never
        return config
    }()

    func get(_ urlString: String, _ params: [String: String]?, completion: ((Data?, URLResponse?, Error?) -> Swift.Void)?) {
        resumeDataTask(with: "GET", urlString, params) { (data, response, error) in
            completion?(data, response, error)
        }
    }

    func post(_ urlString: String, _ params: [String: String]?, completion: ((Data?, URLResponse?, Error?) -> Swift.Void)?) {
        resumeDataTask(with: "POST", urlString, params) { (data, response, error) in
            completion?(data, response, error)
        }
    }

    func resumeDataTask(with method: String,
                        _ urlString: String,
                        _ params: [String: String]?,
                        completion: ((Data?, URLResponse?, Error?) -> Swift.Void)?) {

        guard let urlComp = NSURLComponents(string: urlString) else {
            completion?(nil, nil, nil)
            return
        }

        if let params = params, !params.isEmpty {
            urlComp.addParams(params: params)
        }

        var urlRequest = URLRequest(url: urlComp.url!)
        urlRequest.httpMethod = method

        let session = URLSession(configuration: sessionConfiguration)

        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            completion?(data, response, error)
        })

        task.resume()
    }
}

extension NSURLComponents {

    func addParams(params: [String: String]) {

        var items = [URLQueryItem]()

        for (key, value) in params {
            items.append(URLQueryItem(name: key, value: value))
        }

        items = items.filter {!$0.name.isEmpty}

        if !items.isEmpty {
            queryItems = items
        }
    }
}
