//
//  PhoneLoginViewController.swift
//  BuddyGram
//
//  Created by Mac OSX on 4/24/20.
//  Copyright © 2020 Mac OSX. All rights reserved.
//

import UIKit
import Firebase

class PhoneLoginViewController: UIViewController {
    @IBOutlet weak var down: UIImageView!
    
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var dialCodeLabel: UILabel!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var namefield: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBAction func signIn(_ sender: Any) {
        
        var phoneNumber = String()
        phoneNumber = dialCodeLabel.text!
        var text = phoneField.text!
        
        if text.first == "0" {
            text.removeFirst()
            
        }
        phoneNumber.append(text)
        
        print(phoneNumber)
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
          if let error = error {
            let inputAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            
                let cancelAction = UIAlertAction(title: "OK", style: .default,handler: nil)
                        inputAlert.addAction(cancelAction)
            
                self.present(inputAlert, animated: true, completion: nil)
                return
          }
          // Sign in using the verificationID and the code sent to the user
          UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhoneVerification") as! PhoneVerificationViewController
            
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            vc.name = self.namefield.text!
            vc.phoneNumber = phoneNumber
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var signInButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectCountry))
               countryNameLabel.isUserInteractionEnabled = true
               countryNameLabel.addGestureRecognizer(tap)

        namefield.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
         phoneField.attributedPlaceholder = NSAttributedString(string: "Phone number", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
         
         signInButton.layer.cornerRadius = 20  // this value vary as per your desire
         signInButton.clipsToBounds = true
        if #available(iOS 13, *) {
            cancel.isHidden = true
        }else{
            down.isHidden = true
        }

    }
    
    @objc func selectCountry(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "countryBoard") as! CountryTableViewController
        vc.phoneLoginVC = self
        vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        self.present(vc, animated: true, completion: nil)
    }
    
}
