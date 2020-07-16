//
//  CreateAccountViewController.swift
//  BuddyGram
//
//  Created by Mac OSX on 5/10/20.
//  Copyright © 2020 Mac OSX. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var downArrow: UIImageView!
    @IBAction func toLoginWithPhone(_ sender: Any) {
        self.performSegue(withIdentifier: "toPhoneLogin", sender: nil)
    }
    @IBOutlet weak var createAccountButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        passwordField.isSecureTextEntry = true
        confirmPasswordField.isSecureTextEntry = true
         mailField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
         passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        nameField.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        confirmPasswordField.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
         
         createAccountButton.layer.cornerRadius = 20  // this value vary as per your desire
         createAccountButton.clipsToBounds = true
        
        if #available(iOS 13, *) {
            cancelButton.isHidden = true
        }else{
            downArrow.isHidden = true
        }
    }
    
    @IBAction func createAccount(_ sender: Any) {
        if passwordField.text! == confirmPasswordField.text!{
            Auth.auth().createUser(withEmail: mailField.text!, password: passwordField.text!) { (result, error) in
                if error != nil {
                    let inputAlert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                
                    let cancelAction = UIAlertAction(title: "OK", style: .default,handler: nil)
                    inputAlert.addAction(cancelAction)
                
                    self.present(inputAlert, animated: true, completion: nil)
                }else{
                    let ref = Database.database().reference()
                    let uid = Auth.auth().currentUser?.uid
                    let usersReference = ref.child("users").child(uid!)
                    
                    let values = ["name": self.nameField.text!, "login": self.mailField.text!, "password": self.passwordField.text!]
                    usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                        
                        if err != nil {
                            print(err!)
                            return
                        }
                       
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            }
            
        }else{
                let inputAlert = UIAlertController(title: "Error", message: "Password and confirm password don't match.", preferredStyle: .alert)
            
                let cancelAction = UIAlertAction(title: "OK", style: .default,handler: nil)
                inputAlert.addAction(cancelAction)
            
                self.present(inputAlert, animated: true, completion: nil)
        }
    }
    
    var orientations = UIInterfaceOrientationMask.portrait //or what orientation you want
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
    get { return self.orientations }
    set { self.orientations = newValue }
    }
    
}
