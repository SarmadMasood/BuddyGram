//
//  NewGroupChatViewController.swift
//  BuddyGram
//
//  Created by Sarmad on 04/07/2020.
//  Copyright © 2020 Mac OSX. All rights reserved.
//

import UIKit
import Firebase
@available(iOS 10.0, *)
class NewGroupChatViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var unwindButton: UIBarButtonItem!
    var groupMembers = [Contact]()
    var chatsVC: chatsViewController?

    @IBOutlet weak var startGroupButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var contacts = [Contact]()
     var groupNameField: UITextField?
    
    func groupNameField(textField: UITextField!){
        groupNameField = textField
        groupNameField?.placeholder = "Enter group name here."
    }
    
    func uploadMsgWithValues(values: [String: Any],groupID: String){

           let ref =  Database.database().reference().child("messages")
                  let childRef = ref.childByAutoId()
           childRef.updateChildValues(values)

           let senderRef = Database.database().reference().child("groupMessages").child(groupID)
           senderRef.updateChildValues([childRef.key as! String: ""])

    }
    
    func getUserName(id: String,completion: @escaping (String) -> Void) {
        if let contact = coreDataManager.shared.fetchContact(id: id) {
            completion(contact.value(forKey: "name") as! String)
        }else {
            let ref = Database.database().reference().child("users").child(id).child("name")
                ref.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists() {
                    completion(snapshot.value as! String)
                }
            }
           
        }
    }
    
    @IBAction func startGroup(_ sender: Any) {
        let inputAlert = UIAlertController(title: "Create new group", message: nil, preferredStyle: .alert)
        inputAlert.addTextField(configurationHandler: groupNameField)
        let inputAction = UIAlertAction(title: "Create", style: .default) {(result: UIAlertAction) in
            if self.groupNameField?.text?.count != 0 {
                UIApplication.shared.sendAction(self.unwindButton.action!, to: self.unwindButton.target, from: self, for: nil)
                
                let id = UUID().uuidString
                var members = [String]()
                for m in self.groupMembers {
                    var values = [String: Any]()
                    let uid = m.value(forKey: "id") as! String
                   let ref = Database.database().reference().child("users").child(uid)
                    ref.observeSingleEvent(of: .value) { (snapshot) in
                        if let dic = snapshot.value as? [String: Any]{
                            var temp = dic
                            if dic["groups"] != nil {
                                var groups = dic["groups"] as! [String]
                                groups.append(id)
                                temp["groups"] = groups
                            }else {
                               temp["groups"] = [id]
                            }
                            ref.updateChildValues(temp)
                        }
                    }
                    
                    members.append(m.value(forKey: "id") as! String)
                }
                
                var values = ["name": self.groupNameField?.text,"members": members] as [String : Any]
                let ref = Database.database().reference().child("groups").child(id)
                ref.updateChildValues(values)
                
                values["id"] = id
                coreDataManager.shared.createGroup(dictionary: values)
                
                let currentUserID = Auth.auth().currentUser!.uid
                let timeStamp: NSNumber = NSNumber(value: NSDate().timeIntervalSince1970)
                var msgValues = ["text": "You created this group", "groupID": id, "fromID": "msg1", "timeStamp": timeStamp,"fromUUID": currentUserID] as [String : Any]
                
                coreDataManager.shared.createMessage(dictionary: msgValues)
                self.getUserName(id: currentUserID) { (name) in
                    msgValues["text"] = name+" created this group"
                    self.uploadMsgWithValues(values: msgValues,groupID: id)
                }
                
                let g = coreDataManager.shared.fetchGroup(id: id)
                self.chatsVC!.showChatLogForGroup(group: g!)
            }
        }
        inputAlert.addAction(inputAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel,handler: nil)
        inputAlert.addAction(cancelAction)
        
        self.present(inputAlert, animated: true, completion: nil)
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupContactCell", for: indexPath)
            as! GroupContactCell
        cell.nameLabel.text = contacts[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        groupMembers.append(contacts[indexPath.row])
        
        if groupMembers.count >= 3 {
            startGroupButton.isEnabled = true
        }else{
            startGroupButton.isEnabled = false
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let index = groupMembers.firstIndex(of: contacts[indexPath.row])!
        groupMembers.remove(at: index)
        
        if groupMembers.count >= 3 {
            startGroupButton.isEnabled = true
        }else{
            startGroupButton.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 10.0, *) {
            contacts = coreDataManager.shared.fetchContacts()
            tableView.reloadData()
        } else {
            // Fallback on earlier versions
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isEditing = true
        startGroupButton.isEnabled = false
        // Do any additional setup after loading the view.
    }

}
