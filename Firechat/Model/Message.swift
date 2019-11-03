//
//  Message.swift
//  Firechat
//
//  Created by Subhronil Saha on 01/11/19.
//  Copyright © 2019 Subhronil Saha. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var toId : String?
    var fromId : String?
    var timeStamp : NSNumber?
    var messageText : String?
    
    func chatPartnerId() -> String? {
                        
        if toId == Auth.auth().currentUser?.uid {
            return fromId ?? "User Error"
        }
        else {
            return toId ?? "User Error"
        }
                
    }
    
}
