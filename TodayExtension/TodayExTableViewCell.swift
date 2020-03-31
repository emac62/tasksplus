//
//  TodayExTableViewCell.swift
//  TodayExtension
//
//  Created by Ellen McConomy on 2020-03-27.
//  Copyright © 2020 Ellen McConomy. All rights reserved.
//

import UIKit

class TodayExTableViewCell: UITableViewCell {
	
	@IBOutlet weak var titleLabel: UILabel!
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
