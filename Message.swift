////
////  Message.swift
////  BuddyGram
////
////  Created by Mac OSX on 4/28/20.
////  Copyright © 2020 Mac OSX. All rights reserved.
////
//
//import UIKit
//import Firebase
//
//class Message: NSObject {
//    var toID: String?
//    var fromID: String?
//    var toUUID: String?
//    var fromUUID: String?
//    var text: String?
//    var imageURL: String?
//    var videoURL: String?
//    var fileName: String?
//    var fileExt: String?
//    var fileURL: String?
//    var audioURL: String?
//    var isSeen: String?
//    var audioDuration: NSNumber?
//    var timeStamp: NSNumber?
//    var imageWidth: NSNumber?
//    var imageHeight: NSNumber?
//    
//    init(dictionary: [String: Any]) {
//        super.init()
//        isSeen = dictionary["isSeen"] as? String
//        toID = dictionary["toID"] as? String
//        fromID = dictionary["fromID"] as? String
//        toUUID = dictionary["toUUID"] as? String
//        fromUUID = dictionary["fromUUID"] as? String
//        text = dictionary["text"] as? String
//        timeStamp = dictionary["timeStamp"] as? NSNumber
//        imageURL = dictionary["imageURL"] as? String
//        imageWidth = dictionary["imageWidth"] as? NSNumber
//        imageHeight = dictionary["imageHeight"] as? NSNumber
//        videoURL = dictionary["videoURL"] as? String
//        fileName = dictionary["filename"] as? String
//        fileExt = dictionary["ext"] as? String
//        fileURL = dictionary["fileURL"] as? String
//        audioURL = dictionary["audioURL"] as? String
//        audioDuration = dictionary["audioDuration"] as? NSNumber
//    }
//    
//    func getChatPartnerID() -> String {
//         let email = Auth.auth().currentUser?.email
//               let phone = Auth.auth().currentUser?.phoneNumber
//               var chatPartnerID:  String?
//               if email != nil {
//                   if fromID == email {
//                       chatPartnerID = toID
//                   }
//                   else{
//                       chatPartnerID = fromID
//                   }
//               }else {
//                   if fromID == phone {
//                       chatPartnerID = toID
//                   }
//                   else{
//                       chatPartnerID = fromID
//                   }
//               }
//        return chatPartnerID!
//    }
//    
//    
//    func getChatPartnerUUID() -> String {
//        let uid = Auth.auth().currentUser?.uid
//        
//        var chatPartnerID:  String?
//        
//        if fromUUID == uid {
//            chatPartnerID = toUUID
//        }
//        else{
//            chatPartnerID = fromUUID
//        }
//               
//        return chatPartnerID!
//    }
//    
//}
