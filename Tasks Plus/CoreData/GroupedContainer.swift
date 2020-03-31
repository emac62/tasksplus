//
//  GroupedContainer.swift
//  Tasks Plus
//
//  Created by Ellen McConomy on 2020-03-28.
//  Copyright © 2020 Ellen McConomy. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

class GroupedPersistentCloudKitContainer: NSPersistentCloudKitContainer {

    enum URLStrings: String {
        case group = "group.com.ellen.MyTasksPlus"
    }


    override class func defaultDirectoryURL() -> URL {
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: URLStrings.group.rawValue)

        if !FileManager.default.fileExists(atPath: url!.path) {
            try? FileManager.default.createDirectory(at: url!, withIntermediateDirectories: true, attributes: nil)
        }
        return url!
    }
    
}
