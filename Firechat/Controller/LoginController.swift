//
//  LoginController.swift
//  Firechat
//
//  Created by Subhronil Saha on 26/10/19.
//  Copyright © 2019 Subhronil Saha. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
                     
    @IBOutlet weak var loginRegisterToggle: UISegmentedControl!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
        @IBOutlet weak var nameLabelHeightConstraint: NSLayoutConstraint!
        @IBOutlet weak var nameTextFieldHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginRegisterButton: UIButton!
    
    var messagesController : ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create Done button for keyboard
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneEditing))
        toolbar.setItems([doneButton], animated: false)
        
        emailTextField.inputAccessoryView = toolbar
        nameTextField.inputAccessoryView = toolbar
        passwordTextField.inputAccessoryView = toolbar
        
        // Round off Register button
        loginRegisterButton.layer.cornerRadius = loginRegisterButton.frame.height / 2
        
        // Round off image
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        
    }
    
    // Utility func for Done button in keyboard
    @objc func doneEditing() {
        view.endEditing(true)
    }
    
    //Make status bar white
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- Choose Profile Image
    
    @IBAction func handleSelectProfileImage(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker : UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImage.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
        
    }
    
    //MARK:- Segmented Control Methods
    
    @IBAction func loginRegisterValueChanged(_ sender: Any) {
        
        //Change Button title according to segmented control
        
        let title = loginRegisterToggle.titleForSegment(at: loginRegisterToggle.selectedSegmentIndex)
        
        loginRegisterButton.setTitle(title, for: .normal)
        
        //Remove name text field by setting height to 0
        if loginRegisterToggle.selectedSegmentIndex == 1 {
            nameLabelHeightConstraint.constant = 0
            nameTextFieldHeightConstraint.constant = 0
        }
        else if loginRegisterToggle.selectedSegmentIndex == 0 {
            nameLabelHeightConstraint.constant = 20.5
            nameTextFieldHeightConstraint.constant = 34
        }
        
    }
    
    //MARK:- Login / Register
    
    @IBAction func loginRegisterButtonPressed(_ sender: Any) {
        
        if loginRegisterToggle.selectedSegmentIndex == 0 {
            handleRegister()
        }
        else {
            handleLogin()
        }
        
    }
    
    //MARK:- Register
    func handleRegister() { // Register Functions
        
        guard let email = emailTextField.text, let name = nameTextField.text, let password = passwordTextField.text
        else {
            print("Form invalid")
            return
        }
                
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                print(error!)
            }
            else {
                
                // Registered Successfully :D
                
                print("\nRegistration successful\n")
                
                let imageName = NSUUID().uuidString
                
                let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
                
                if let uploadData = self.profileImage.image?.jpegData(compressionQuality: 0.1) {
                    
                    storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                        
                        if error != nil {
                            print(error!)
                            return
                        }
                        

                        storageRef.downloadURL(completion: { (url, error) in
                            if let downloadURL = url {
                            
                                let uid = Auth.auth().currentUser?.uid

                                let values = ["email" : email, "name" : name, "profileImageURL" : downloadURL.absoluteString]
                                
                                self.registerUserIntoDatabaseWithUID(uid: uid!, values: values as [String : AnyObject], name: name)
                                
                                
                            }
                            else {
                                return
                                
                            }
                        })
                        
                    }
                    
                }
                
                
            }
            
        }
        
    }
    
    func registerUserIntoDatabaseWithUID(uid : String, values : [String : AnyObject], name: String) {
        
        let usersDB = Database.database().reference().child("users")
        
        let user = Auth.auth().currentUser
        
        usersDB.child(user!.uid).updateChildValues(values)
        
        messagesController?.fetchUserAndUpdateNavbar()
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //MARK:- Login
    func handleLogin() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text
        else {
            print("Form invalid")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                print(error!)
            }
            else {
                
                //Login successful :D
                print("\nLogin successful\n")
                
                //Instant Navbar title update
                self.messagesController?.fetchUserAndUpdateNavbar()
                
                self.dismiss(animated: true, completion: nil)
                
            }
        }
        
    }
    

    
}
