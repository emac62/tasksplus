//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Ellen McConomy on 2020-03-27.
//  Copyright © 2020 Ellen McConomy. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreData

class TodayViewController: UIViewController, NCWidgetProviding, NSFetchedResultsControllerDelegate {
        
	@IBOutlet weak var tableView: UITableView!
	
	var managedObjectContext: NSManagedObjectContext!
//	var fetchedResultsController: NSFetchedResultsController<Task>!
	lazy var coreDataStack = CoreDataStack()

	lazy var container: GroupedPersistentCloudKitContainer? = coreDataStack.persistentContainer as? GroupedPersistentCloudKitContainer

    var fetchedResultsController: NSFetchedResultsController<Task>? {
        didSet {
            fetchedResultsController?.delegate = self
        }
    }
	
//	var items : [Task] = []
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		
		extensionContext?.widgetLargestAvailableDisplayMode = .expanded
		getTodaysTasks()
    }
	
	func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let expanded = activeDisplayMode == .expanded
        preferredContentSize = expanded ? CGSize(width: maxSize.width, height: 200) : maxSize
    }
	
	override func viewWillAppear(_ animated: Bool) {
		getTodaysTasks()
	}
    
	
	
	func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
	
	func getTodaysTasks() {
	
		guard let context = container?.viewContext else {
            return
        }

        context.performAndWait {
            let request: NSFetchRequest<Task> = Task.fetchRequest()
            let filterPredicate = NSPredicate(format: "hasDueDate == %@ && dueDate < %@", NSNumber(value: true), Date().endOfDay as CVarArg)
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
                tableView.reloadData()
            } catch {
                // Handle the error, for example, present an alert
            }
        }

	}
    
}

extension TodayViewController: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		var numberOfRows = 0
		
		let items = fetchedResultsController?.sections?[section].numberOfObjects
        
		if items == 0 {
            numberOfRows = 1
        } else {
			numberOfRows = items!
        }
        return numberOfRows
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "todayCell") as? TodayExTableViewCell else { fatalError("Could not dequeue a cell")}
		
//		let cell = tableView.dequeueReusableCell(withIdentifier: "todayCell") as? TodayExTableViewCell
		
		let items = fetchedResultsController?.fetchedObjects
		
		if items!.count == 0 {
            cell.titleLabel?.text = "There are no tasks due today."
        } else {
        
			let item = items![indexPath.row]
        cell.titleLabel?.text = item.title
            
            if item.dueDate! < Date().startOfDay {
                cell.titleLabel.textColor = .red
            } else {
                cell.titleLabel.textColor = .black
            }
        }
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.extensionContext?.open(NSURL(string: "emacTasksPlus://")! as URL, completionHandler: nil)
	}
	
}
