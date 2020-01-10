//
//  ChatLogController.swift
//  Firechat
//
//  Created by Subhronil Saha on 30/10/19.
//  Copyright © 2019 Subhronil Saha. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var user : User? //Message Recipient
    
    var messageDict = [Message : Int]()
    var messages = [Message]()
    
    @IBOutlet var messageTableView: UITableView!
    
    @IBOutlet var messageTextContainerView: UIView!
    
    @IBOutlet var messageContainerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup table view cells
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 600
        
        messageTableView.register(UINib(nibName: "SentMessageCell", bundle: nil), forCellReuseIdentifier: "sentMessageCell")
        messageTableView.register(UINib(nibName: "ReceivedMessageCell", bundle: nil), forCellReuseIdentifier: "receivedMessageCell")
        
        messageTableView.separatorColor = .clear
        
        // Create Done button for keyboard
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneEditing))
        toolbar.setItems([doneButton], animated: false)
        
        messageTextField.inputAccessoryView = toolbar
        
        // Set message text field delegate
        messageTextField.delegate = self
        messageTextField.sizeToFit()
        
        // Display Message Receiver name on navbar
        if let currentUser = user {
            navigationItem.title = currentUser.name
        }
        
        // Move to list of chats
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Chats", style: .plain, target: self, action: #selector(popAllVC))
        
        observeMessages()
        
        // Listen for Keyboard tap
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

    }
    
    //MARK:- Selector functions
    @objc func doneEditing() {
        view.endEditing(true)
        
        // Decrease text field height
        messageContainerHeight.constant = 60
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        //print("Keyboard will show \(notification.name.rawValue)")
        
        // Get Keyboard Rectangle dimensions
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        // Increase textfield height on tap
        messageContainerHeight.constant = keyboardRect.height + 55
        
    }
    
    @objc func popAllVC() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK:- Observe Messages
    
    func observeMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return } // Current user's fromId
        let fromRef = Database.database().reference().child("user-messages").child(uid)
        fromRef.observe(.childAdded) { (snapshot) in
            
            let messageId = snapshot.key
            let messageAction = snapshot.value as? Int //Sent: 1, Received: 2
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observe(.value) { (snapshot) in
                
                guard let dict = snapshot.value as? [String : AnyObject] else {return}
                
                let toId = dict["toId"] as? String
                let fromId = dict["fromId"] as? String
                
                if toId == self.user?.id || fromId == self.user?.id {
                    
                    let message = Message()
                    message.messageText = dict["messageText"] as? String
                    message.fromId = dict["fromId"] as? String
                    message.toId = dict["toId"] as? String
                    message.timeStamp = dict["timeStamp"] as? NSNumber
                    
                    if messageAction == 1 {
                        
                        self.messageDict[message] = 1
                        
                    }
                    else if messageAction == 2 {
                        
                        self.messageDict[message] = 2
                        
                    }
                    
                    self.messages.append(message)
                    self.messages.sort { (message1, message2) -> Bool in
                        
                        let timestamp1 = message1.timeStamp?.intValue ?? 0
                        let timestamp2 = message2.timeStamp?.intValue ?? 0

                        // Descending order sort
                        return timestamp1 < timestamp2
                        
                    }
                }
                
                
                DispatchQueue.main.async {
                    self.messageTableView.reloadData()
                }
                
            }
            
        }
                
    }
    
    
    //MARK:- Send Action
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        
        let messagesRef = Database.database().reference().child("messages")
        let childRef = messagesRef.childByAutoId()
        
        let toId = user?.id
        let fromId = Auth.auth().currentUser?.uid
        let timeStamp : NSNumber = NSNumber(value: NSDate().timeIntervalSince1970)
        let messageText = messageTextField.text!
        
        let values = ["toId" : toId ?? "none" , "fromId" : fromId ?? "none" , "timeStamp" : timeStamp , "messageText" : messageText] as [String : Any]
        
        childRef.updateChildValues(values) { (error, ref) in
            
            if error != nil {
                print(error!)
                return
            }
            
            guard let messageId = childRef.key else { return }
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId ?? "none").child(messageId)
            userMessagesRef.setValue(1) //Sent
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId ?? "none").child(messageId)
            recipientUserMessagesRef.setValue(2) //Received
            
            
        }
        
        
        
        messageTextField.text = ""
        
    }
    
    
    //MARK:- Table view delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
        
    }
    
    
//    Note:-
//    To create a spacing of 10 pts above the initial message,
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        
        // Sent message
        if messageDict[message] == 1 {
            
            let senderCell = messageTableView.dequeueReusableCell(withIdentifier: "sentMessageCell", for: indexPath) as! SentMessageCell
                        
                
            if let uid = Auth.auth().currentUser?.uid {
                let userRef = Database.database().reference().child("users").child(uid)
                userRef.observe(.value) { (snapshot) in
                    
                    if let dict = snapshot.value as? [String : AnyObject] {
                        
                        let profileImgURL = dict["profileImageURL"] as? String
                        senderCell.senderImage.loadImageUsingCacheUsingUrlString(urlString: profileImgURL ?? "None")
                        
                        
                        
                    }
                }
            }
            
            
            senderCell.sentMessage.text = message.messageText
            
            return senderCell
            
        }
            
        // Received message
        else {
            let receivedCell = messageTableView.dequeueReusableCell(withIdentifier: "receivedMessageCell", for: indexPath) as! ReceivedMessageCell
            
            receivedCell.receiverImage.loadImageUsingCacheUsingUrlString(urlString: user?.profileImageUrl ?? "None")
            
            receivedCell.receivedText.text = message.messageText
            
            return receivedCell
        }
        
    }
    
    
}
