//
//  Group+CoreDataProperties.swift
//  
//
//  Created by Sarmad on 12/07/2020.
//
//

import Foundation
import CoreData


extension Group {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Group> {
        return NSFetchRequest<Group>(entityName: "Group")
    }

    @NSManaged public var desc: String?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var members: [String]?

}
