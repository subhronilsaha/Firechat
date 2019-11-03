//
//  ViewController.swift
//  Firechat
//
//  Created by Subhronil Saha on 26/10/19.
//  Copyright © 2019 Subhronil Saha. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {
    
    let main = UIStoryboard(name: "Main", bundle: nil)
        
    var messageDictionary = [String : Message]()
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "NewMessageCell", bundle: nil), forCellReuseIdentifier: "newMessageCell")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let image = UIImage(named: "newMessageIcon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
        
        observeUserMessages()
        
    }
    
    
    //MARK:- Check if user is logged in
    
    func checkIfUserIsLoggedIn() {
        
        // On starting first time it will go to log in screen
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        else { //User is logged in
            
            fetchUserAndUpdateNavbar()
            
        }
    }
    
    //MARK:- Fetch Users, Update Navbar
    
    func fetchUserAndUpdateNavbar() {
        
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        Database.database().reference().child("users").child(uid).observe(.value) { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                
                //Display his/her name
                self.navigationItem.title = dictionary["name"] as? String
                
                self.messages.removeAll()
                self.messageDictionary.removeAll()
                self.observeUserMessages()

            }
        }
        
    }
    
    
    //MARK:- Handle Logout
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
            print("\nLogged Out\n")
        }
        catch let logOutError {
            print(logOutError)
        }
        
        //Move to Login Page
        let loginController = main.instantiateViewController(identifier: "loginController") as! LoginController
        loginController.messagesController = self
        loginController.modalPresentationStyle = .fullScreen
        
        present(loginController, animated: true, completion: nil)
        
    }
    
    //MARK:- Go to New messages
    
    @objc func handleNewMessage() {
        
        //Move to New Messages Page
        let newMessageController = main.instantiateViewController(identifier: "newMessageController")
        navigationController?.show(newMessageController, sender: self)
        
    }
    
    //MARK:- Observe User Messages
    
    func observeUserMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded) { (snapshot) in
            
            let messageId = snapshot.key
            print(messageId)
            let messagesReference = Database.database().reference().child("messages").child(messageId)
            
            messagesReference.observe(.value) { (snapshot) in
                
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    let message = Message()
                    
                    message.toId = dictionary["toId"] as? String
                    message.fromId = dictionary["fromId"] as? String
                    message.timeStamp = dictionary["timeStamp"] as? NSNumber
                    message.messageText = dictionary["messageText"] as? String
                    
                    // Displays only the latest message per user
                    if let toId = message.chatPartnerId() {
                        
                        // Store only latest message per user in dictionary
                        self.messageDictionary[toId] = message
                        
                        // Store message values from dictionary in list
                        self.messages = Array(self.messageDictionary.values)
                        
                        // Sort messages according to timestamp. Display latest up top.
                        self.messages.sort { (message1, message2) -> Bool in
                            
                            let timestamp1 = message1.timeStamp?.intValue ?? 0
                            let timestamp2 = message2.timeStamp?.intValue ?? 0

                            // Descending order sort
                            return timestamp1 > timestamp2
                        }
                        
                    }
                    
                    // Sets a timer for 0,1 second
                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReload), userInfo: nil, repeats: false)
                    
                    
                }
            }
        }
        
    }
    
    
    // Fix for wrong & flickering images in cells
    
    var timer : Timer?
    
    @objc func handleReload() {
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
//    Observe Message TableView
//
//    func observeMessages() {
//
//        let messageRef = Database.database().reference().child("messages")
//        messageRef.observe(.childAdded) { (snapshot) in
//
//            if let dictionary = snapshot.value as? [String : AnyObject] {
//                let message = Message()
//
//                message.toId = dictionary["toId"] as? String
//                message.fromId = dictionary["fromId"] as? String
//                message.timeStamp = dictionary["timeStamp"] as? NSNumber
//                message.messageText = dictionary["messageText"] as? String
//
//                // Displays only the latest message per user
//                if let toId = message.toId {
//
//                    // Store only latest message per user in dictionary
//                    self.messageDictionary[toId] = message
//
//                    // Store message values from dictionary in list
//                    self.messages = Array(self.messageDictionary.values)
//
//                    // Sort messages according to timestamp. Display latest up top.
//                    self.messages.sort { (message1, message2) -> Bool in
//
//                        let timestamp1 = message1.timeStamp?.intValue ?? 0
//                        let timestamp2 = message2.timeStamp?.intValue ?? 0
//
//                        // Descending order sort
//                        return timestamp1 > timestamp2
//                    }
//
//                }
//
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//
//
//            }
//
//        }
//
//    }
    
    //MARK:- Table View Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "newMessageCell", for: indexPath) as! NewMessageCell
        
        setupMessageCells(cell: cell, indexPath: indexPath)
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else { return }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observe(.value) { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String : AnyObject] else { return }
            
            let user = User()
            user.name = dictionary["name"] as? String ?? "Name not found"
            user.email = dictionary["email"] as? String ?? "Email not found"
            user.profileImageUrl = dictionary["profileImageURL"] as? String ?? "Profile Image not found"
            user.id = chatPartnerId 
            
            self.showChatLogController(user: user)
            
        }
        
    }
    
    //MARK:- Show Chat Log Controller
    
    @objc func showChatLogController(user: User) {
        
        let chatLogController = main.instantiateViewController(identifier: "chatLogController") as ChatLogController
        chatLogController.user = user
        navigationController?.show(chatLogController, sender: self)
        
    }
    
    //MARK:- Setup message rows
    
    func setupMessageCells(cell: NewMessageCell, indexPath: IndexPath) {
        
        let messageRow = messages[indexPath.row]
        
        // Set Profile Image and Name
        if let id = messageRow.chatPartnerId() {
            
            let ref = Database.database().reference().child("users").child(id)
            ref.observe(.value) { (snapshot) in
                
                if let dict = snapshot.value as? [String : AnyObject] {
                    
                    cell.nameLabel.text = dict["name"] as? String
                    
                    if let profileImgURL = dict["profileImageURL"] {
                        cell.profileImage.loadImageUsingCacheUsingUrlString(urlString: profileImgURL as! String)
                    }
                }
                
            }
        }
        
        // Get Timestamp
        if let seconds = messageRow.timeStamp?.doubleValue {
            
            let timeStampDate = NSDate(timeIntervalSince1970: seconds)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            cell.timeStampLabel.text = dateFormatter.string(from: timeStampDate as Date)
        }
        
        cell.subtitleTextLabel.text = messageRow.messageText
    }

}

