//
//  SentMessageCell.swift
//  Firechat
//
//  Created by Subhronil Saha on 02/11/19.
//  Copyright © 2019 Subhronil Saha. All rights reserved.
//

import UIKit

class SentMessageCell: UITableViewCell {

    @IBOutlet var messageView: UIView!
    @IBOutlet var senderImage: UIImageView!
    @IBOutlet var sentMessage: UILabel!
    @IBOutlet var messageTopHeight: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Round off the images
        senderImage.layer.cornerRadius = senderImage.frame.height / 2
        messageView.layer.cornerRadius = 20
        sentMessage.sizeToFit()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
