//
//  Persistence.swift
//  RickMortyEpisodeFeed
//
//  Created by Artyom Nesterenko on 14/09/2023.
//

import Foundation
import CoreData

struct PersistenceController: CoreDataPublishing {
    
    static let shared = PersistenceController(name: "RickMortyEpisodeFeed")
    
    static var preview: PersistenceController = {
        return PersistenceController(name: "RickMortyEpisodeFeed", inMemory: true)
    }()
    
    let container: NSPersistentContainer
    
    init(name: String, inMemory: Bool = false) {
        container = NSPersistentContainer(name: name)
        setupIfMemoryStorage(inMemory)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
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
        })
    }

    private func setupIfMemoryStorage(_ inMemory: Bool) {
        guard inMemory else {
            return
        }
        
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        self.container.persistentStoreDescriptions = [description]
    }
}
