//
//  CoreDataManager.swift
//  BuddyGram
//
//  Created by Mac OSX on 5/21/20.
//  Copyright © 2020 Mac OSX. All rights reserved.
//

import CoreData
import UIKit

struct coreDataManager {
    static let shared = coreDataManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Accounter")
        container.loadPersistentStores{(storeDescription, error) in
            if let error = error {
                fatalError("Failed to load store \(error)")
            }
        }
        return container
    }()
    
    func createRecordCell(date: String,budget: Int,id: Int32){
        let context = persistentContainer.viewContext
        let recordCell = NSEntityDescription.insertNewObject(forEntityName: "RecordCell", into: context)
        
        recordCell.setValue(id, forKey: "id")
        recordCell.setValue(date, forKey: "date")
        recordCell.setValue(budget, forKey: "budget")
        
        do {
            try context.save()
        } catch let error {
            print("Failed to save record cell", error)
        }
    }
    
    func fetchRecordCell() -> [RecordCell]{
        let context = persistentContainer.viewContext
        
        let fetchRequest =  NSFetchRequest<RecordCell>(entityName: "RecordCell")
        
        do {
            let recordCell = try context.fetch(fetchRequest)
            return recordCell
        } catch let error {
            print("Failed to fetch record cell", error)
            return []
        }
    }
    
    func deleteRecordCell(id: Int32){
        let context = persistentContainer.viewContext
        
        let fetchRequest =  NSFetchRequest<RecordCell>(entityName: "RecordCell")
        
        do {
            let recordCells = try context.fetch(fetchRequest)
            recordCells.forEach { (fetchedRecord) in
                if(fetchedRecord.id == id){
                    context.delete(fetchedRecord)
                }
            }
        } catch let error {
            print("Failed to delete record cell", error)
            
        }
    }
    

    
    //deletes all instances of a entity
    func deleteAll(entity: String){
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
         let context = persistentContainer.viewContext
        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            print(error)
        }
    }
   
    
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

