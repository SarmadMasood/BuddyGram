//
//  Message+CoreDataProperties.swift
//  
//
//  Created by Mac OSX on 5/23/20.
//
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var audioDuration: NSNumber?
    @NSManaged public var audioURL: String?
    @NSManaged public var fileExt: String?
    @NSManaged public var fileName: String?
    @NSManaged public var fileURL: String?
    @NSManaged public var fromID: String?
    @NSManaged public var fromUUID: String?
    @NSManaged public var imageHeight: NSNumber?
    @NSManaged public var imageURL: String?
    @NSManaged public var imageWidth: NSNumber?
    @NSManaged public var isSeen: String?
    @NSManaged public var text: String?
    @NSManaged public var timeStamp: NSNumber?
    @NSManaged public var toID: String?
    @NSManaged public var toUUID: String?
    @NSManaged public var videoURL: String?

}
