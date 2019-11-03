//
//  NewMessageController.swift
//  Firechat
//
//  Created by Subhronil Saha on 28/10/19.
//  Copyright © 2019 Subhronil Saha. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    let main = UIStoryboard(name: "Main", bundle: nil)
    
    var users = [User]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "New Message"
        
        tableView.register(UINib(nibName: "NewMessageCell", bundle: nil), forCellReuseIdentifier: "newMessageCell")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(goToUserPage))
        
        fetchUsers()
        
    }
    
    @objc func goToUserPage() {
           
        let userPageController = main.instantiateViewController(identifier: "userPageController")

        present(userPageController, animated: true, completion: nil)
           
    }
    
    //MARK:- Fetch users from Firebase
    
    func fetchUsers() {
        
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                
                let user = User()
                user.name = dictionary["name"] as? String ?? "Name not found"
                user.email = dictionary["email"] as? String ?? "Email not found"
                user.profileImageUrl = dictionary["profileImageURL"] as? String ?? "Profile Image not found"
                user.id = snapshot.key

                //print(user.name!, user.email!)
                
                self.users.append(user)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }
        
    }
    
    //MARK:- Table View Delegate Methods
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//            let headerView = UIView()
//        headerView.backgroundColor = UIColor(displayP3Red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9)
//
//            let headerLabel = UILabel(frame: CGRect(x: 15, y: 15, width:
//                tableView.bounds.size.width, height: tableView.bounds.size.height))
//            headerLabel.font = UIFont(name: "AvenirNext-Bold", size: 25)
//            headerLabel.textColor = .systemPink
//            headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
//            headerLabel.sizeToFit()
//            headerView.addSubview(headerLabel)
//
//            return headerView
//        }
//
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 60
//    }
//
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//
//        let header = "New Message"
//
//        return header
//
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "newMessageCell", for: indexPath) as! NewMessageCell
        
        let user = users[indexPath.row]
        
        cell.nameLabel.text = user.name
        cell.subtitleTextLabel.text = user.email
        cell.profileImage.image = UIImage(named: "Blank-DP")
        
        if let profileImgURL = user.profileImageUrl {
            
            cell.profileImage.loadImageUsingCacheUsingUrlString(urlString: profileImgURL)

        }
        
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = self.users[indexPath.row]
        
        showChatLogController(user: user)
    }
    
    //MARK:- Show Chat Log Controller
    
    func showChatLogController(user: User) {
        
        let chatLogController = main.instantiateViewController(identifier: "chatLogController") as ChatLogController
        chatLogController.user = user
        navigationController?.show(chatLogController, sender: self)
        
    }
    
    
}



