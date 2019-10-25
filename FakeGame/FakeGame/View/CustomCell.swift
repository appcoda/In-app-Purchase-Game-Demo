//
//  CustomCell.swift
//  FakeGame
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var itemImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var remainingLabel: UILabel!
    
    @IBOutlet weak var lockedImageView: UIImageView!
        
    @IBOutlet weak var topSeparator: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
