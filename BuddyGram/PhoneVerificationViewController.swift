//
//  PhoneVerificationViewController.swift
//  BuddyGram
//
//  Created by Mac OSX on 4/25/20.
//  Copyright © 2020 Mac OSX. All rights reserved.
//

import UIKit
import Firebase

class PhoneVerificationViewController: UIViewController {
    
    var name = String()
    var phoneNumber = String()

    @IBAction func verify(_ sender: Any) {
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")!
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
        verificationCode: codeField.text!)
        
        Auth.auth().signIn(with: credential) { (result, error) in
            if error != nil {
                let inputAlert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                           
                               let cancelAction = UIAlertAction(title: "OK", style: .default,handler: nil)
                                       inputAlert.addAction(cancelAction)
                           
                               self.present(inputAlert, animated: true, completion: nil)
                               return
            }
            
            let values = ["name": self.name,"login": self.phoneNumber,"password": ""]
                let uid = Auth.auth().currentUser?.uid
            let ref = Database.database().reference(fromURL: "https://buddygram.firebaseio.com/")
                let userRef = ref.child("users").child(uid!)
            userRef.updateChildValues(values,withCompletionBlock: {(err,ref)in
                if err != nil {
                    print(err)
                }
            })
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "home") as! HomeViewController
                                   vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                                   self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var codeField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        verifyButton.layer.cornerRadius = 20  // this value vary as per your desire
        verifyButton.clipsToBounds = true
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
