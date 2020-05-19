//
//  ViewController.swift
//  BuddyGram
//
//  Created by Mac OSX on 4/20/20.
//  Copyright © 2020 Mac OSX. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController ,UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBAction func signInAction(_ sender: Any) {
//        Auth.auth().signIn(withEmail: mailField.text ?? "", password: passField.text ?? "", completion: {(result,error) in
//            if error != nil {
//                let inputAlert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
//
//                let cancelAction = UIAlertAction(title: "OK", style: .default,handler: nil)
//                inputAlert.addAction(cancelAction)
//
//                self.present(inputAlert, animated: true, completion: nil)
//            }
//            else{
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "home") as! HomeViewController
//                vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
//                self.present(vc, animated: true, completion: nil)
//            }
//        })

        let vc = self.storyboard?.instantiateViewController(withIdentifier: "home") as! HomeViewController
                        vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                        self.present(vc, animated: true, completion: nil)

    }
    
    
    @IBAction func takeToCreateAccountScreen(_ sender: Any) {
        self.performSegue(withIdentifier: "toCAVC", sender: nil)
    }
    @IBOutlet weak var singInButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        passField.isSecureTextEntry = true
        mailField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        passField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
       
        
        singInButton.layer.cornerRadius = 20  // this value vary as per your desire
        singInButton.clipsToBounds = true
    }
    
    var orientations = UIInterfaceOrientationMask.portrait //or what orientation you want
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
    get { return self.orientations }
    set { self.orientations = newValue }
    }
    @IBAction func cancelToSignIn(_ segue: UIStoryboardSegue) {
        
    }
 
}


