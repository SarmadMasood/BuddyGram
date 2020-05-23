//
//  CoreDataManager.swift
//  BuddyGram
//
//  Created by Mac OSX on 5/21/20.
//  Copyright © 2020 Mac OSX. All rights reserved.
//

import CoreData
import UIKit

@available(iOS 10.0, *)
struct coreDataManager {
    static let shared = coreDataManager()
   // let delegate = UIApplication.shared.delegate as! AppDelegate

    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BuddyGram")
        container.loadPersistentStores{(storeDescription, error) in
            if let error = error {
                fatalError("Failed to load store \(error)")
            }
        }
        return container
    }()

    func createMessage(dictionary: [String: Any]){
         let context = persistentContainer.viewContext
        
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context)
        

        message.setValue(dictionary["isSeen"], forKey: "isSeen")
        message.setValue(dictionary["toID"], forKey: "toID")
        message.setValue(dictionary["fromID"], forKey: "fromID")
        message.setValue(dictionary["toUUID"], forKey: "toUUID")
        message.setValue(dictionary["fromUUID"], forKey: "fromUUID")
        message.setValue(dictionary["text"], forKey: "text")
        message.setValue(dictionary["timeStamp"], forKey: "timeStamp")
        message.setValue(dictionary["imageURL"], forKey: "imageURL")
        message.setValue(dictionary["imageWidth"], forKey: "imageWidth")
        message.setValue(dictionary["imageHeight"], forKey: "imageHeight")
        message.setValue(dictionary["videoURL"], forKey: "videoURL")
        message.setValue(dictionary["filename"], forKey: "fileName")
        message.setValue(dictionary["ext"], forKey: "fileExt")
        message.setValue(dictionary["fileURL"], forKey: "fileURL")
        message.setValue(dictionary["audioURL"], forKey: "audioURL")
        message.setValue(dictionary["audioDuration"], forKey: "audioDuration")

        do {
            try context.save()
        } catch let error {
            print("Failed to save message", error)
        }
    }

    func fetchMessages() -> [Message]{
        let context = persistentContainer.viewContext
       
        let fetchRequest =  NSFetchRequest<Message>(entityName: "Message")

        do {
            let message = try context.fetch(fetchRequest)
            return message
        } catch let error {
            print("Failed to fetch message", error)
            return []
        }
        print("fetched...")
    }
    
    
    
    func fetchSortedMessages() -> [Message]{
        let context = persistentContainer.viewContext
       
        let fetchRequest =  NSFetchRequest<Message>(entityName: "Message")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: true)]

        do {
            let message = try context.fetch(fetchRequest)
            return message
        } catch let error {
            print("Failed to fetch message", error)
            return []
        }
        print("fetched...")
    }

    func deleteMessage(timeStamp: NSNumber){
        let context = persistentContainer.viewContext

        let fetchRequest =  NSFetchRequest<Message>(entityName: "Message")

        do {
            let messages = try context.fetch(fetchRequest)
            messages.forEach { (fetchedMessage) in
                if((fetchedMessage.timeStamp?.isEqual(to: timeStamp))!){
                    context.delete(fetchedMessage)
                }
            }
        } catch let error {
            print("Failed to delete message", error)

        }
    }
    
    func updateMessage(timeStamp: NSNumber,key: String,value: String){
        let context = persistentContainer.viewContext

        let fetchRequest =  NSFetchRequest<Message>(entityName: "Message")

        do {
            let messages = try context.fetch(fetchRequest)
            messages.forEach { (fetchedMessage) in
                if((fetchedMessage.timeStamp?.isEqual(to: timeStamp))!) && fetchedMessage.isSeen == "false"{
                    fetchedMessage.setValue(value, forKey: key)
                }
            }
            try context.save()
        } catch let error {
            print("Failed to delete message", error)

        }
    }

    //deletes all instances of a entity
    func deleteAll(entity: String){
        let context = persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
         
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

