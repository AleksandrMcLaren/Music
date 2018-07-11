//
//  DataSource.swift
//
//  Created by Aleksandr on 06/06/2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import CoreData

let moc = DataSource.shared.context

class DataSource {
    var modelName: String

    static let shared: DataSource = DataSource()
    private init() {
        modelName = "MusicModel"
    }

    lazy var managedObjectModel: NSManagedObjectModel = {
        let url = Bundle.main.url(forResource: modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: url)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let storeUrl = documentsURL?.appendingPathComponent(modelName + ".sqlite")

        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: nil)
        } catch let error as NSError {
            do {
                try FileManager.default.removeItem(at: storeUrl!)
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: nil)
            } catch let error as NSError {
                print("DataSource persistentStoreCoordinator error \(error.localizedDescription)")
                abort()
            }
        }

        return coordinator
    }()

    lazy var context: NSManagedObjectContext = {

        let coordinator = persistentStoreCoordinator
        var context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator

        return context
    }()
}

extension NSManagedObjectContext {

    func needsSave() {
        let context = DataSource.shared.context

        context.performAndWait {
            if context.hasChanges {
                do {
                    try context.save()
                } catch let error as NSError {
                    print("DataSource saveContext error \(error.localizedDescription)")
                }
            }
        }
    }
}
