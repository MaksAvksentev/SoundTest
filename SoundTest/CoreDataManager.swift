//
//  CoreDataManager.swift
//  SoundCloud
//
//  Created by Maksim Avksentev on 05.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    
    private static var sharedManager = CoreDataManager()
    
    static var shared: CoreDataManager {
        
        return sharedManager
    }
    
    private let persistentContainer: NSPersistentContainer = NSPersistentContainer(name: "SoundTest")
    
    private override init() {
        
        super.init()
    }
    
    var viewContext: NSManagedObjectContext {
        
        return self.persistentContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext {
        
        return self.persistentContainer.newBackgroundContext()
    }
    
    func initialize(completionHandler: @escaping (Bool) -> Void = {_ in}) {
        
        self.persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            guard error == nil else {
                //FIXME: - log error
                completionHandler(false)
                return
            }
            self.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            completionHandler(true)
        })
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        
        self.persistentContainer.performBackgroundTask(block)
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
