//
//  Persistence.swift
//  Stuff
//
//  Created by Danis Tazetdinov on 07.12.2021.
//

import CoreData
import Logger

public struct PersistenceController {
    public static let shared = PersistenceController()
    public static let sharedLocal = PersistenceController(local: true)

    public let container: NSPersistentContainer

    init(local: Bool = false) {
        guard let model = NSManagedObjectModel.mergedModel(from: [Bundle.module]) else {
            fatalError("could not locate data model")
        }
        let storeName: String
#if DEBUG
        storeName = "Stuff-debug"
#else
        storeName = "Stuff"
#endif

        container = NSPersistentCloudKitContainer(name: storeName, managedObjectModel: model)
        guard let storeDescription = container.persistentStoreDescriptions.first else {
            return
        }
        
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        if !local {
            storeDescription.url = AppGroupManager.shared.appGroupContainer.appendingPathComponent("\(storeName).sqlite")
        }

        container.loadPersistentStores { [container] (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
//            do {
//                try container.initializeCloudKitSchema(options: [.printSchema])
//            } catch {
//                Logger.default.error("failed to initialize CloudKit schema: \(error)")
//            }
            DispatchQueue.main.async {
                container.viewContext.automaticallyMergesChangesFromParent = true
            }
        }
    }
}
