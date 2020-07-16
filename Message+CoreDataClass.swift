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
    
    func getChatPartnerID() -> String {
        let email = Auth.auth().currentUser?.email
        let phone = Auth.auth().currentUser?.phoneNumber
        var chatPartnerID:  String?
        
        if groupID != nil {
            chatPartnerID=groupID
        }else{
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
        }
        return chatPartnerID!
    }
    
    
    func getChatPartnerUUID() -> String {
        
        let uid = Auth.auth().currentUser?.uid
        var chatPartnerID:  String?
        
        if groupID != nil {
            chatPartnerID=groupID
        }else{
            if fromUUID == uid {
                chatPartnerID = toUUID
            }
            else{
                chatPartnerID = fromUUID
            }
        }
        
        return chatPartnerID!
    }
    
}
