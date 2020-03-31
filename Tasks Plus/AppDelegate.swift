//
//  AppDelegate.swift
//  Tasks Plus
//
//  Created by Ellen McConomy on 2020-03-25.
//  Copyright © 2020 Ellen McConomy. All rights reserved.
//

import UIKit
import CoreData
import CloudKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	lazy var coreDataStack = CoreDataStack()
	var managedObjectContext: NSManagedObjectContext!
	lazy var container: GroupedPersistentCloudKitContainer? = coreDataStack.persistentContainer as? GroupedPersistentCloudKitContainer
	
	var fetchedResultsController: NSFetchedResultsController<Task>!
	
	private func requestNotificationAuthorization(application: UIApplication) {
		   
		   let center = UNUserNotificationCenter.current()
		   let options: UNAuthorizationOptions = [.alert, .badge]
		   
		   center.requestAuthorization(options: options) { granted, error in
			   if let error = error {
				   print(error.localizedDescription)
			   }
		   }
	   }
	
	
	
	//Update the badge number at midnight - iOS won't run updateBadge - need background fetch??
    
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		_ = container?.viewContext
		
		requestNotificationAuthorization(application: application)
		
		
		return true
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		coreDataStack.saveContext()
	
		
	}

	// MARK: UISceneSession Lifecycle

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	
	}

	
	func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
       
        if url.scheme == "emacTasksPlus" {
            
        }
        return true
    }

}


