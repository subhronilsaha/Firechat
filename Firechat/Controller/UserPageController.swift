//
//  UserPageController.swift
//  Firechat
//
//  Created by Subhronil Saha on 03/11/19.
//  Copyright © 2019 Subhronil Saha. All rights reserved.
//

import UIKit
import Firebase

class UserPageController: UIViewController {

    @IBOutlet var profileImageView: UIImageView!
    
    @IBOutlet var nameTextLabel: UILabel!
    
    var messages = [Message]()
    var messageDictionary = [String : Message]()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        
        setupUserPage()
        
    }
    
    func setupUserPage() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let ref = Database.database().reference().child("users").child(uid)
        ref.observe(.value) { (snapshot) in
            
            guard let dict = snapshot.value as? [String : AnyObject] else {return}
            
            let imageURL = dict["profileImageURL"] as? String
            let name = dict["name"] as? String
            
            self.profileImageView.loadImageUsingCacheUsingUrlString(urlString: imageURL!)
            self.nameTextLabel.text = name
            
        }
        
    }
    
    @IBAction func clearButtonPressed(_sender: Any) {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let messagesRef = Database.database().reference().child("messages")
        let userMessageRef = Database.database().reference().child("user-messages").child(uid)
        
        messagesRef.removeValue()
        userMessageRef.removeValue()
        
        messages.removeAll()
        messageDictionary.removeAll()
        
    }
    

}
