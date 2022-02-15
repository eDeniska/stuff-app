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

    public static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.identifier = UUID()
            newItem.lastModified = Date()
        }
        viewContext.saveOrRollback()
        return result
    }()

    public let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        guard let model = NSManagedObjectModel.mergedModel(from: [Bundle.module]) else {
            fatalError("could not locate data model")
        }
        container = NSPersistentCloudKitContainer(name: "Stuff", managedObjectModel: model)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            container.persistentStoreDescriptions.first?.url = FileStorageManager.shared.appGroupContainer.appendingPathComponent("StuffData.sqlite")
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
