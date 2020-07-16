//
//  CoreDataManager.swift
//  BuddyGram
//
//  Created by Mac OSX on 5/21/20.
//  Copyright © 2020 Mac OSX. All rights reserved.
//

import CoreData
import UIKit
import Firebase

@available(iOS 10.0, *)
struct coreDataManager {
    static let shared = coreDataManager()

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
        message.setValue(dictionary["replyTimeStamp"], forKey: "replyTimeStamp")
        message.setValue(dictionary["groupID"], forKey: "groupID")
            
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
    }
    
    func fetchMessage(timeStamp: NSNumber) -> Message? {
        let context = persistentContainer.viewContext
       
        let fetchRequest =  NSFetchRequest<Message>(entityName: "Message")
        let predicate = NSPredicate(format: "timeStamp == %@", timeStamp)
        fetchRequest.predicate = predicate

        do {
            let messages = try context.fetch(fetchRequest)
            if messages.count > 0 {
                return messages[0]
            }else {return nil}
        } catch let error {
            print("Failed to fetch Message", error)
            return nil
        }
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
    
    func deleteMessage(timeStamp: NSNumber){
        let context = persistentContainer.viewContext

        let fetchRequest =  NSFetchRequest<Message>(entityName: "Message")

        do {
            let messages = try context.fetch(fetchRequest)
            messages.forEach { (fetchedMessage) in
                if((fetchedMessage.timeStamp?.isEqual(to: timeStamp))!){
                    context.delete(fetchedMessage)
                    print("deleted")
                }
            }
        } catch let error {
            print("Failed to delete message", error)

        }
    }
    
    func createContact(dictionary: [String: Any]){
         let context = persistentContainer.viewContext
        
        let contact = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: context)
        
        contact.setValue(dictionary["id"], forKey: "id")
        contact.setValue(dictionary["name"], forKey: "name")
        contact.setValue(dictionary["email"], forKey: "email")
        contact.setValue(dictionary["phone"], forKey: "phone")
        contact.setValue(dictionary["imageURL"], forKey: "imageURL")
        contact.setValue(dictionary["groups"], forKey: "groups")
        
        do {
            try context.save()
        } catch let error {
            print("Failed to save Contact", error)
        }
    }
    
    func fetchContact(id: String) -> Contact? {
        let context = persistentContainer.viewContext
       
        let fetchRequest =  NSFetchRequest<Contact>(entityName: "Contact")
        let predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.predicate = predicate

        do {
            let contacts = try context.fetch(fetchRequest)
            if contacts.count > 0 {
                return contacts[0]
            }else {return nil}
        } catch let error {
            print("Failed to fetch Contact", error)
            return nil
        }
    }
    
    func fetchContacts() -> [Contact]{
        let context = persistentContainer.viewContext
        
         let fetchRequest =  NSFetchRequest<Contact>(entityName: "Contact")

         do {
             let contacts = try context.fetch(fetchRequest)
             return contacts
         } catch let error {
             print("Failed to fetch Contact", error)
             return []
         }
    }
    
    func updateContact(id: String,key: String,value: String){
        let context = persistentContainer.viewContext

        let fetchRequest =  NSFetchRequest<Contact>(entityName: "Contact")

        do {
            let contacts = try context.fetch(fetchRequest)
            contacts.forEach { (fetchedContact) in
                if((fetchedContact.id?.isEqual(id))!){
                    fetchedContact.setValue(value, forKey: key)
                }
            }
            try context.save()
        } catch let error {
            print("Failed to delete Contact", error)

        }
    }
    
    func deleteContact(id: String){
        let context = persistentContainer.viewContext

        let fetchRequest =  NSFetchRequest<Contact>(entityName: "Contact")

        do {
            let contacts = try context.fetch(fetchRequest)
            contacts.forEach { (fetchedContact) in
                if((fetchedContact.id?.isEqual(id))!){
                    context.delete(fetchedContact)
                    print("deleted")
                }
            }
        } catch let error {
            print("Failed to delete Contact", error)

        }
    }
    
    func createGroup(dictionary: [String: Any]){
        let context = persistentContainer.viewContext
        
        let group = NSEntityDescription.insertNewObject(forEntityName: "Group", into: context)
        
        group.setValue(dictionary["id"], forKey: "id")
        group.setValue(dictionary["name"], forKey: "name")
        group.setValue(dictionary["members"], forKey: "members")
        
        do {
            try context.save()
        } catch let error {
            print("Failed to save Group", error)
        }
    }
    
    func fetchGroups() -> [Group]{
        let context = persistentContainer.viewContext
       
        let fetchRequest =  NSFetchRequest<Group>(entityName: "Group")

        do {
            let groups = try context.fetch(fetchRequest)
            return groups
        } catch let error {
            print("Failed to fetch Group", error)
            return []
        }
        
    }
    
    func fetchGroup(id: String) -> Group? {
        let context = persistentContainer.viewContext
       
        let fetchRequest =  NSFetchRequest<Group>(entityName: "Group")
        let predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.predicate = predicate

        do {
            let groups = try context.fetch(fetchRequest)
            if groups.count > 0 {
                return groups[0]
            }else {return nil}
        } catch let error {
            print("Failed to fetch Group", error)
            return nil
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
    
    //    func fetchMessages(timeStamp: NSNumber) -> [Message]{
    //        let context = persistentContainer.viewContext
    //
    //        let fetchRequest =  NSFetchRequest<Message>(entityName: "Message")
    //        fetchRequest.predicate = NSPredicate(format: "timeStamp == %@", timeStamp)
    //
    //        do {
    //            let message = try context.fetch(fetchRequest)
    //            return message
    //        } catch let error {
    //            print("Failed to fetch message", error)
    //            return []
    //        }
    //
    //    }
}

