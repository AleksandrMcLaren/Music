//
//  FileData.swift
//  Music
//
//  Created by Aleksandr on 15.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation

protocol FileDataPresentable: class {
    init(with urlString: String, to destinationPath: String)

    var urlString: String { get set }
    var destinationPath: String { get set }
    var progress: ((Float) -> Swift.Void)? { get set }
    var completion: ((_ success: Bool) -> Swift.Void)? { get set }
}

class FileData: FileDataPresentable {

    required init(with urlString: String, to destinationPath: String) {
        self.urlString = urlString
        self.destinationPath = destinationPath
    }

    var urlString: String
    var destinationPath: String
    var progress: ((Float) -> Swift.Void)?
    var completion: ((_ success: Bool) -> Swift.Void)?

    var task: URLSessionDownloadTask?

    func url() -> URL? {

        if let url = URL(string: urlString) {
            return url
        }

        var ss = urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        ss = ss?.replacingOccurrences(of: "+", with: "%2B")

        if let ss = ss,
            let url = URL(string: ss) {
            return url
        }

        return nil
    }

    func taskResume() {
        task?.resume()
    }

    func finish(_ success: Bool) {
        DispatchQueue.main.async {
            self.completion?(success)
        }
    }

    func fileExists() -> Bool {
        return FileManager.default.fileExists(atPath: destinationPath)
    }
}
