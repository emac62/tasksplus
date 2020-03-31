//
//  Task+CoreDataProperties.swift
//  Tasks Plus
//
//  Created by Ellen McConomy on 2020-03-25.
//  Copyright © 2020 Ellen McConomy. All rights reserved.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

	@NSManaged public var title: String?
    @NSManaged public var isComplete: Bool
    @NSManaged public var hasDueDate: Bool
    @NSManaged public var dueDate: Date?
    @NSManaged public var notes: String?
    @NSManaged public var createdOn: Date
	
	static var entityName: String { return "Task" }

}
