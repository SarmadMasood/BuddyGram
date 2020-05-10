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
    
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var namefield: UITextField!
    @IBOutlet weak var phonefield: UITextField!
    @IBAction func signIn(_ sender: Any) {
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phonefield.text!, uiDelegate: nil) { (verificationID, error) in
          if let error = error {
            let inputAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            
                let cancelAction = UIAlertAction(title: "OK", style: .default,handler: nil)
                        inputAlert.addAction(cancelAction)
            
                self.present(inputAlert, animated: true, completion: nil)
                return
          }
          // Sign in using the verificationID and the code sent to the user
          UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            print(verificationID)
            print(self.phonefield.text)
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhoneVerification") as! PhoneVerificationViewController
//            let transition = CATransition()
//            transition.duration = 0.5
//            transition.type = CATransitionType.push
//            transition.subtype = CATransitionSubtype.fromRight
//            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
//            vc.view.window!.layer.add(transition, forKey: kCATransition)
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            vc.name = self.namefield.text!
            vc.phoneNumber = self.phonefield.text!
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var signInButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        namefield.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
         phonefield.attributedPlaceholder = NSAttributedString(string: "Phone number with country code", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
         
         signInButton.layer.cornerRadius = 20  // this value vary as per your desire
         signInButton.clipsToBounds = true
        if #available(iOS 13, *) {
            cancel.isHidden = true
        }else{
            down.isHidden = true
        }

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
