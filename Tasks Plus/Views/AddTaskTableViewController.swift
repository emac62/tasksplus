//
//  AddTaskTableViewController.swift
//  Tasks Plus
//
//  Created by Ellen McConomy on 2020-03-25.
//  Copyright © 2020 Ellen McConomy. All rights reserved.
//

import UIKit
import CoreData

class AddTaskTableViewController: UITableViewController {
	
	var managedObjectContext: NSManagedObjectContext!
	var task: Task!
	
	@IBOutlet weak var titleTextField: UITextField!
	@IBOutlet weak var isCompleteButton: UIButton!
	@IBOutlet weak var hasDueDateSwitch: UISwitch!
	@IBOutlet weak var dueDateLabel: UILabel!
	@IBOutlet weak var dueDatePickerView: UIDatePicker!
	@IBOutlet weak var notesTextView: UITextView!
	@IBOutlet weak var saveButton: UIBarButtonItem!
	
	var isDueDateLabelHidden = true
	var isDatePickerViewHidden = true
	
	override func viewDidLoad() {
        super.viewDidLoad()

		if let task = task {
            navigationItem.title = "Update Task"
            titleTextField.text = task.title
            isCompleteButton.isSelected = task.isComplete
            hasDueDateSwitch.isOn = task.hasDueDate
            if hasDueDateSwitch.isOn {
                isDueDateLabelHidden = false
                dueDatePickerView.date = task.dueDate!
            } else {
                dueDateLabel.text = "Not Set"
            }
            notesTextView.text = task.notes
            
        } else {
            dueDatePickerView.date = Date()
            DispatchQueue.main.async {
                self.titleTextField.becomeFirstResponder()
            }
        }
        updateSaveButtonState()
    }
	//Task must have a title to be saved
	func updateSaveButtonState()  {
		let text = titleTextField.text ?? ""
		saveButton.isEnabled = !text.isEmpty
	}
	//Task title must be updated to enable the save button
	@IBAction func textEditingChanged(_ sender: UITextField) {
		updateSaveButtonState()
	}
	
	//Tap return on the keybord to dismiss it so the rest of the view can be seen
	@IBAction func returnPressed(_ sender: UITextField) {
		titleTextField.resignFirstResponder()
	}
	
	//Toggle isComplete button
	@IBAction func isCompleteButtonTapped(_ sender: UIButton) {
		isCompleteButton.isSelected = !isCompleteButton.isSelected
	}
	
	@IBAction func hasDueDateSwitch(_ sender: UISwitch) {
		if hasDueDateSwitch.isOn {
			isDueDateLabelHidden = false
			isDatePickerViewHidden = false
		} else {
			isDueDateLabelHidden = true
			isDatePickerViewHidden = true
		}
		tableView.reloadData()
	}
	
	
	
	//Format the date
	var dueDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		return formatter
	}()
	
	func updateDueDateLabel(date: Date)  {
		dueDateLabel.text = dueDateFormatter.string(from: date)
	}
	
	@IBAction func dueDatePickerChanged(_ sender: UIDatePicker) {
		updateDueDateLabel(date: dueDatePickerView.date)
	}
	
	

    // MARK: - Table view data source

	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.01
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		   let hiddenCellHeight = CGFloat(0)
		   let normalCellHeight = CGFloat(52)
		   let largeCellHeight = CGFloat(225)
		   
		   switch(indexPath) {
		   case [0,2]: //Due Date Label
			   updateDueDateLabel(date: dueDatePickerView.date)
			   return hasDueDateSwitch.isOn ? normalCellHeight : hiddenCellHeight
		   case [1,0]: //Due Date Cell
			   return isDatePickerViewHidden ? hiddenCellHeight : largeCellHeight
		   case [2,0]: // Notes Cell
			   return largeCellHeight
		   default:
			   return normalCellHeight
		   }
	   }
	   
	   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		   switch (indexPath) {
		   case [0,1]:
			   isDueDateLabelHidden = !isDueDateLabelHidden
			   tableView.beginUpdates()
			   titleTextField.resignFirstResponder()
			   tableView.endUpdates()
		   case [0,2]:
			   isDatePickerViewHidden = !isDatePickerViewHidden
			   tableView.beginUpdates()
			   titleTextField.resignFirstResponder()
			   tableView.endUpdates()
		   default:
			   break
		   }
	   }

  
	@IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
		if self.task == nil {
			self.task = (NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: self.managedObjectContext) as! Task)
		}
			self.task.title = titleTextField.text
			self.task.isComplete = isCompleteButton.isSelected
			self.task.hasDueDate = self.hasDueDateSwitch.isOn
			if self.hasDueDateSwitch.isOn {
				self.task.dueDate = self.dueDatePickerView.date
			} else {
				self.task.dueDate = nil
			}
			self.task.notes = self.notesTextView.text
			self.task.createdOn = Date()
		
		do {
			try self.managedObjectContext.save()
			_ = self.navigationController?.popViewController(animated: true)
		} catch  {
			let alert = UIAlertController(title: "Trouble Saving",
                                          message: "Something went wrong when trying to save the Blog Idea.  Please try again...",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: .default,
                                         handler: {(action: UIAlertAction) -> Void in
                                            self.managedObjectContext.rollback()
                                            self.task = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: self.managedObjectContext) as? Task
			})
			alert.addAction(okAction)
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	
	

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
		self.managedObjectContext.rollback()
            
    }
  

}
