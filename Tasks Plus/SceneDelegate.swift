//
//  SceneDelegate.swift
//  Tasks Plus
//
//  Created by Ellen McConomy on 2020-03-25.
//  Copyright © 2020 Ellen McConomy. All rights reserved.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate, NSFetchedResultsControllerDelegate {

	var window: UIWindow?
	
	lazy var coreDataStack = CoreDataStack()
	var managedObjectContext: NSManagedObjectContext!
	lazy var container: GroupedPersistentCloudKitContainer? = coreDataStack.persistentContainer as? GroupedPersistentCloudKitContainer
	var fetchedResultsController: NSFetchedResultsController<Task>? {
		didSet {
			fetchedResultsController?.delegate = self
		}
	}

	var badgeCountResult: Int? = 0
    

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
		// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
		// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
		guard let _ = (scene as? UIWindowScene) else { return }
		
		let navigationController = self.window?.rootViewController as! UINavigationController
        let mainVC = navigationController.viewControllers[0] as! TasksTableViewController
        
        let viewContext = coreDataStack.persistentContainer.viewContext
        viewContext.automaticallyMergesChangesFromParent = true

        mainVC.managedObjectContext = viewContext

	}

	func sceneDidDisconnect(_ scene: UIScene) {
		// Called as the scene is being released by the system.
		// This occurs shortly after the scene enters the background, or when its session is discarded.
		// Release any resources associated with this scene that can be re-created the next time the scene connects.
		// The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
		updateBadge()
	}

	func sceneDidBecomeActive(_ scene: UIScene) {
		// Called when the scene has moved from an inactive state to an active state.
		// Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
	}

	func sceneWillResignActive(_ scene: UIScene) {
		// Called when the scene will move from an active state to an inactive state.
		// This may occur due to temporary interruptions (ex. an incoming phone call).
		updateBadge()
	}

	func sceneWillEnterForeground(_ scene: UIScene) {
		// Called as the scene transitions from the background to the foreground.
		// Use this method to undo the changes made on entering the background.
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
		// Called as the scene transitions from the foreground to the background.
		// Use this method to save data, release shared resources, and store enough scene-specific state information
		// to restore the scene back to its current state.

		// Save changes in the application's managed object context when the application transitions to the background.
		coreDataStack.saveContext()
		updateBadge()
	}
	
	func getTasksForBadge() {
		guard let context = container?.viewContext else {
            return
        }

        context.performAndWait {
            let request: NSFetchRequest<Task> = Task.fetchRequest()
            let filterPredicate = NSPredicate(format: "hasDueDate == %@ && dueDate < %@ && isComplete == %@", NSNumber(value: true), Date().endOfDay as CVarArg, NSNumber(value: false))
			request.predicate = filterPredicate
			let sort = NSSortDescriptor(key: "dueDate", ascending: true)
			request.sortDescriptors = [sort]

            fetchedResultsController = NSFetchedResultsController<Task>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

		
		do {
			try fetchedResultsController!.performFetch()
            
        } catch {
            print("Fetching Failed")
        }
		
		}
	}
		
	func updateBadge() {
		getTasksForBadge()
		
		badgeCountResult = self.fetchedResultsController?.fetchedObjects?.count ?? 0
		
//		badgeCountResult = self.fetchedResultsController?.fetchedObjects?.count as! Int
		UIApplication.shared.applicationIconBadgeNumber = badgeCountResult ?? 0
	}
		
	func applicationSignificantTimeChange(_ application: UIApplication) {
			updateBadge()
		}
	

}

