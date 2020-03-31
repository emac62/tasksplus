//
//  TasksTableViewController.swift
//  Tasks Plus
//
//  Created by Ellen McConomy on 2020-03-25.
//  Copyright © 2020 Ellen McConomy. All rights reserved.
//

import UIKit
import CoreData

class TasksTableViewController: UITableViewController, TaskTableViewCellDelegate {
	
	var managedObjectContext: NSManagedObjectContext!
	var fetchedResultsController: NSFetchedResultsController<Task>!
	
	
	func checkmarkTapped(sender: TaskTableViewCell) {
		if let indexPath = tableView.indexPath(for: sender) {
			let task = fetchedResultsController.object(at: indexPath)
			task.isComplete = !task.isComplete
			
			do {
				try self.managedObjectContext.save()
			} catch {
				print("isComplete toggle error")
			}
			
		}
		
	}
	
	@IBAction func filterButton(_ sender: UIBarButtonItem) {
		let sheet = UIAlertController(title: "Filter Options", message: nil, preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
        }))
        sheet.addAction(UIAlertAction(title: "Show All", style: .default, handler: { (action) -> Void in
            self.getTasks(dueDateFilter: "Show All")
            self.navigationItem.title = "My Tasks"
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }))
        sheet.addAction(UIAlertAction(title: "Overdue", style: .default, handler: { (action) -> Void in
            self.getTasks(dueDateFilter: "Overdue")
            self.navigationItem.title = "Overdue Tasks"
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }))
        sheet.addAction(UIAlertAction(title: "Due Today", style: .default, handler: { (action) -> Void in
            self.getTasks(dueDateFilter: "Due Today")
            self.navigationItem.title = "Today's Tasks"
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }))
        sheet.addAction(UIAlertAction(title: "Future", style: .default, handler: { (action) -> Void in
            self.getTasks(dueDateFilter: "Future")
            self.navigationItem.title = "Future Tasks"
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }))
        sheet.addAction(UIAlertAction(title: "No Due Date", style: .default, handler: { (action) -> Void in
            self.getTasks(dueDateFilter: "No Due Date")
            self.navigationItem.title = "No Due Date"
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }))
		
		sheet.view.tintColor = .label
		
		if let popoverController = sheet.popoverPresentationController {
		  popoverController.barButtonItem = sender 
		}
		
        self.present(sheet, animated: true, completion: nil)
	}
	
	
	func getTasks(dueDateFilter: String? = nil) {
		let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        let sort = NSSortDescriptor(key: "dueDate", ascending: true)
        fetchRequest.sortDescriptors = [sort]
		self.fetchedResultsController = NSFetchedResultsController<Task>(
			fetchRequest: fetchRequest,
			managedObjectContext: self.managedObjectContext,
			sectionNameKeyPath: nil,
			cacheName: nil)
		
		self.fetchedResultsController.delegate = self
		
		if let dueDateFilter = dueDateFilter {
            if dueDateFilter == "Overdue" {
                let filterPredicate = NSPredicate(format: "hasDueDate == %@ && dueDate < %@", NSNumber(value: true), Date().startOfDay as CVarArg)
                fetchedResultsController.fetchRequest.predicate = filterPredicate
            } else if dueDateFilter == "Due Today" {
                let filterPredicate = NSPredicate(format: "dueDate >= %@ && dueDate <= %@", Date().startOfDay as CVarArg, Date().endOfDay as CVarArg)
                fetchedResultsController.fetchRequest.predicate = filterPredicate
            } else if dueDateFilter == "Future" {
                let filterPredicate = NSPredicate(format: "dueDate > %@", Date().endOfDay as CVarArg)
                fetchedResultsController.fetchRequest.predicate = filterPredicate
            } else if dueDateFilter == "No Due Date" {
                let filterPredicate = NSPredicate(format: "hasDueDate == %@", NSNumber(value: false))
                fetchedResultsController.fetchRequest.predicate = filterPredicate
            } else if dueDateFilter == "Show All" {
                let filterPredicate = NSPredicate(format: "isComplete == %@", NSNumber(value: false))
                fetchedResultsController.fetchRequest.predicate = filterPredicate
            }
        }
		
		do {
            try fetchedResultsController.performFetch()
            
        } catch {
            print("Fetching Failed")
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
	}

	@objc func updateDate() {
        getTasks()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        refreshControl?.endRefreshing()
    }
	
	

    override func viewDidLoad() {
        super.viewDidLoad()

		self.navigationItem.leftBarButtonItem = self.editButtonItem
		navigationController?.navigationBar.prefersLargeTitles = true
		
		let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateDate), for: .valueChanged)
        
        self.tableView.refreshControl = refreshControl
    }
	
	override func viewWillAppear(_ animated: Bool) {
		getTasks()
		DispatchQueue.main.async {
            self.tableView.reloadData()
        }
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
	
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell") as? TaskTableViewCell

		cell?.delegate = self
		
		
		
		let task = fetchedResultsController.object(at: indexPath)
		
		cell!.isCompleteButton.isSelected = task.isComplete
		
		if task.isComplete {
			cell!.taskTitleLabel.attributedText = task.title?.strikeThrough()
		} else {
			cell!.taskTitleLabel.text = task.title
		}
		
		if task.hasDueDate {
            if task.dueDate! < Date().startOfDay {
				cell!.taskTitleLabel.textColor = .red
            } else if task.dueDate! > Date().startOfDay && task.dueDate! < Date().endOfDay {
				if #available(iOS 13.0, *) {
					cell!.taskTitleLabel.textColor = .label
				} else {
					// Fallback on earlier versions
					cell!.taskTitleLabel.textColor = .black
				}
            } else {
                // future due date
                cell!.taskTitleLabel.textColor = UIColor(red: 100/255.0, green: 100/255.0, blue: 100/255.0, alpha: 1)
            }
        } else {
            //no dueDate
            cell!.taskTitleLabel.textColor = UIColor(red: 125/255.0, green: 125/255.0, blue: 125/255.0, alpha: 1)
        }
		return cell!
    }
   

 
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
   

   
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
			let task = fetchedResultsController.object(at: indexPath)
			self.managedObjectContext.delete(task)
			
			do {
                try self.managedObjectContext.save()
            } catch {
                self.managedObjectContext.rollback()
                print("Something went wrong: \(error)")
            }
		
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
  

   
    // MARK: - Navigation

	@IBAction func unwindToTasksList(segue: UIStoryboardSegue) {
		
	}
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		guard let editorVC = segue.destination as? AddTaskTableViewController else { return }
		editorVC.managedObjectContext = self.managedObjectContext
		
		if let selectedIndePath = self.tableView.indexPathForSelectedRow {
			let selectedTask = self.fetchedResultsController.object(at: selectedIndePath)
			editorVC.task = selectedTask
		}
		
    }
  

}

extension TasksTableViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        let index = indexPath ?? (newIndexPath ?? nil)
        guard let cellIndex = index else { return }

        switch type {
			case .insert:
				tableView.insertRows(at: [cellIndex], with: .automatic)
			case .delete:
				tableView.deleteRows(at: [cellIndex], with: .automatic)
			case .update:
				tableView.reloadRows(at: [cellIndex], with: .automatic)
			default:
				break
        }
    }


    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension String {
	func strikeThrough() -> NSAttributedString {
		let completeTask = NSMutableAttributedString(string: self)
			completeTask.addAttributes([
							NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
							NSAttributedString.Key.strikethroughColor: UIColor.darkGray,
							NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12.0)
						], range: NSMakeRange(0, completeTask.length))
			return completeTask
		}
}
