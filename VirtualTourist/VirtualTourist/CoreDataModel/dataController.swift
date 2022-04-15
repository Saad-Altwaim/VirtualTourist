//
//  dataController.swift
//  VirtualTourist
//
//  Created by Saad altwaim on 9/28/21.
//  Copyright © 2021 Saad Altwaim. All rights reserved.
//

import Foundation
import CoreData

class DataController
{
    let persistentContainer : NSPersistentContainer
    var viewContext : NSManagedObjectContext
    {
        return persistentContainer.viewContext
    }
    
    var backgroundContext :NSManagedObjectContext!
    
    init(modelName : String)
    {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion : ( () -> Void )? = nil )
    {
        persistentContainer.loadPersistentStores
        {
            (storeDescription, error) in
            guard error == nil
            
            else
            {
                fatalError(error!.localizedDescription)
            }
            
            self.configureContext()

            completion?()
        }
    }
    
    func configureContext()
    {
        backgroundContext = persistentContainer.newBackgroundContext()
        
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
    
}
