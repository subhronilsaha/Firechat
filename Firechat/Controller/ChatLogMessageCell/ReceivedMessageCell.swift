//
//  ReceivedMessageCell.swift
//  Firechat
//
//  Created by Subhronil Saha on 02/11/19.
//  Copyright © 2019 Subhronil Saha. All rights reserved.
//

import UIKit

class ReceivedMessageCell: UITableViewCell {

    @IBOutlet var receiverImage: UIImageView!
    @IBOutlet var receivedText: UILabel!
    @IBOutlet var messageView: UIView!
    @IBOutlet var messageTopHeight: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Round off the images
        receiverImage.layer.cornerRadius = receiverImage.frame.height / 2
        messageView.layer.cornerRadius = 20
        

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
