//
//  DownloadManager.swift
//  Music
//
//  Created by Aleksandr on 12.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation

/** Класс скачивает файл, список файлов по ссылкам.
    Пропускает скачивание следующей по списку ссылки
    если файл по ссылке уже скачен или находится в процессе скачивания,
    например, другим экземпляром FileDownloader. */

protocol FileDownloaderPresentable: class {
    /// Методы старта загрузки
    func download(_ data: FileData)
    func download(_ data: [FileData])
    /// Закрывает все task и вызывает invalidateAndCancel()
    func cancel()
    /// Вернет true если скачал весь список ссылок иначе false
    var completion: ((_ success: Bool) -> Swift.Void)? { get set }
}

class FileDownloader: NSObject, FileDownloaderPresentable {

    deinit {
       
    }

    var completion: ((_ success: Bool) -> Swift.Void)?

    fileprivate let sessions = DownloaderSessions.shared
    fileprivate var taskQueue = [FileData]()
    fileprivate lazy var taskSession: URLSession = {
        let config = URLSessionConfiguration.default // background(withIdentifier: "com.music.downloadManager")
        let taskSession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        return taskSession
    }()

    // MARK: FileDownloaderPresentable

    func download(_ data: FileData) {
        download([data])
    }

    func download(_ data: [FileData]) {

        for data in data {
            if let url = data.url() {
                data.task = taskSession.downloadTask(with: url)
                taskQueue.append(data)
            }
        }

        removeNextDownloadedLinks()

        if let data = taskQueue.first {
            sessions.setUrl(data.urlString, for: taskSession)
            data.taskResume()
        } else {
            taskSession.finishTasksAndInvalidate()
            completionAsync(true)
        }
    }

    func cancel() {
        if taskQueue.count > 0 {
            taskSession.invalidateAndCancel()
        } else {
            taskSession.finishTasksAndInvalidate()
            completionAsync(false)
        }
    }

    // MARK: - Flow control

    func downloadFinish(_ task: URLSessionDownloadTask, to location: URL) {

        completionTask(task, location)
        sessions.removeSession(taskSession)
        removeNextDownloadedLinks()

        if let fileData = taskQueue.first {
            sessions.setUrl(fileData.urlString, for: taskSession)
            fileData.taskResume()
        } else {
            taskSession.finishTasksAndInvalidate()
            completionAsync(true)
        }
    }

    fileprivate func completionTask(_ task: URLSessionDownloadTask, _ location: URL) {

        if let i = taskQueue.index(where: { $0.task == task }) {
            let fileData = taskQueue[i]
            var fileMoved = false

            if let httpResponse = task.response as? HTTPURLResponse, httpResponse.statusCode != 404 {
                do {
                    let file = URL(fileURLWithPath: fileData.destinationPath)
                    try FileManager.default.moveItem(at: location, to: file)
                    fileMoved = true
                } catch let error {
                    print("Error: \(error.localizedDescription)")
                }
            }

            fileData.finish(fileMoved)
            taskQueue.remove(at: i)
        }
    }

    fileprivate func progressTask(_ task: URLSessionDownloadTask, progress: Float) {
        if let i = taskQueue.index(where: { $0.task == task }) {
            let data = taskQueue[i]

            DispatchQueue.main.async {
                data.progress?(progress)
            }
        }
    }

    fileprivate func cancelTasks() {

        for downloadData in taskQueue {
            downloadData.finish(false)
        }

        taskQueue.removeAll()
        sessions.removeSession(taskSession)
        completionAsync(false)
    }

    func completionAsync(_ success: Bool) {
        DispatchQueue.main.async {
            self.completion?(success)
        }
    }

    /// удаляет следующие в очереди скаченные и в процессе скачивания ссылки
    fileprivate func removeNextDownloadedLinks() {
        while taskQueue.count > 0 {
            if let data = taskQueue.first,
                (data.fileExists() || sessions.urlDownloading(data.urlString)) {
                taskQueue.remove(at: 0)
            } else {
                break
            }
        }
    }
}

extension FileDownloader: URLSessionDelegate, URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {

        if totalBytesExpectedToWrite > 0 {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            progressTask(downloadTask, progress: progress)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        downloadFinish(downloadTask, to: location)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            /// ошибка или отменили загрузку методом cancel()
            cancelTasks()
        }
    }
}
