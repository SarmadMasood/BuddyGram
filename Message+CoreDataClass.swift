//
//  Message+CoreDataClass.swift
//  
//
//  Created by Mac OSX on 5/21/20.
//
//

import Foundation
import CoreData
import Firebase

@objc(Message)
public class Message: NSManagedObject {
    
//    func initializeUsingDictionary(dictionary: [String: Any]) {
//        isSeen = dictionary["isSeen"] as? String
//        toID = dictionary["toID"] as? String
//        fromID = dictionary["fromID"] as? String
//        toUUID = dictionary["toUUID"] as? String
//        fromUUID = dictionary["fromUUID"] as? String
//        text = dictionary["text"] as? String
//        timeStamp = (dictionary["timeStamp"] as? NSNumber)!
//        imageURL = dictionary["imageURL"] as? String
//        imageWidth = (dictionary["imageWidth"] as? NSNumber)!
//        imageHeight = (dictionary["imageHeight"] as? NSNumber)!
//        videoURL = dictionary["videoURL"] as? String
//        fileName = dictionary["filename"] as? String
//        fileExt = dictionary["ext"] as? String
//        fileURL = dictionary["fileURL"] as? String
//        audioURL = dictionary["audioURL"] as? String
//        audioDuration = (dictionary["audioDuration"] as? NSNumber)!
//    }

    
    func getChatPartnerID() -> String {
         let email = Auth.auth().currentUser?.email
               let phone = Auth.auth().currentUser?.phoneNumber
               var chatPartnerID:  String?
               if email != nil {
                   if fromID == email {
                       chatPartnerID = toID
                   }
                   else{
                       chatPartnerID = fromID
                   }
               }else {
                   if fromID == phone {
                       chatPartnerID = toID
                   }
                   else{
                       chatPartnerID = fromID
                   }
               }
        return chatPartnerID!
    }
    
    
    func getChatPartnerUUID() -> String {
        let uid = Auth.auth().currentUser?.uid
        
        var chatPartnerID:  String?
        
        if fromUUID == uid {
            chatPartnerID = toUUID
        }
        else{
            chatPartnerID = fromUUID
        }
               
        return chatPartnerID!
    }
    
}
