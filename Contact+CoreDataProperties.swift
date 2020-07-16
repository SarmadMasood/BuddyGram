//
//  Contact+CoreDataProperties.swift
//  
//
//  Created by Sarmad on 13/07/2020.
//
//

import Foundation
import CoreData


extension Contact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }

   
    @NSManaged public var groups: [String]?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var phone: String?
    @NSManaged public var email: NSString?

}
