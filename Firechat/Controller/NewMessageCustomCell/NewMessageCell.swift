//
//  NewMessageCell.swift
//  Firechat
//
//  Created by Subhronil Saha on 28/10/19.
//  Copyright © 2019 Subhronil Saha. All rights reserved.
//

import UIKit

class NewMessageCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var subtitleTextLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
        
    @IBOutlet var timeStampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        timeStampLabel.text = ""
        profileImage.layer.cornerRadius = 30
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
