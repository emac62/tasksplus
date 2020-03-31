//
//  TaskTableViewCell.swift
//  Tasks Plus
//
//  Created by Ellen McConomy on 2020-03-25.
//  Copyright © 2020 Ellen McConomy. All rights reserved.
//

import UIKit

protocol TaskTableViewCellDelegate: class {
	func checkmarkTapped(sender: TaskTableViewCell)
}

class TaskTableViewCell: UITableViewCell {
	
	weak var delegate: TaskTableViewCellDelegate?
	
	@IBOutlet weak var isCompleteButton: UIButton!
	@IBOutlet weak var taskTitleLabel: UILabel!
	
	@IBAction func isCompleteButtonTapped(_ sender: UIButton) {
		delegate?.checkmarkTapped(sender: self)
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		isCompleteButton.isSelected = false
		taskTitleLabel.attributedText = nil
	}
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
