//
//  NewChatViewController.swift
//  BuddyGram
//
//  Created by Mac OSX on 4/23/20.
//  Copyright © 2020 Mac OSX. All rights reserved.
//

import UIKit
import Contacts
import Firebase

@available(iOS 10.0, *)
class NewChatViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate{
    
    var chatsVC: chatsViewController?
    @IBOutlet weak var tableView: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return filteredContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatCell", for: indexPath)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
            as! ContactTableViewCell
        cell.nameLabel.text = filteredContacts[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 80
        }
        return 50
    }
    
    var contacts = [User]()
    var filteredContacts = [Contact]()
    
    override func viewDidDisappear(_ animated: Bool) {
        Database.database().reference().child("users").removeAllObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        filteredContacts = coreDataManager.shared.fetchContacts()
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    func fetchContacts()  {
//        
//        let store = CNContactStore()
//        store.requestAccess(for: .contacts) { (granted, error) in
//            if let err = error{
//                print("Failed to access contacts",err)
//                return
//            }
//            if granted{
//                print("Access Granted to contacts.")
//                let keys = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactEmailAddressesKey,CNContactPhoneNumbersKey]
//                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
//                
//                
//                do {
//                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopNumeratingPointer) in
//                        var c = User()
//                        c.name = contact.givenName
//                        c.name?.append(" ")
//                        c.name?.append(contact.familyName)
//                        
//                        c.phone = contact.phoneNumbers.first?.value.stringValue ?? ""
//                        let phone = String(c.phone!.filter { !" \n\t\r".contains($0) })
//                        c.phone = phone
//                        
//                        c.email = contact.emailAddresses.first?.value ?? ""
//                        self.contacts.append(c)
//                        })
//                    
//                } catch let err {
//                    print(err)
//                }
//            
//        }
//    }
//        
//}
    
//    func fetchUsersWithReload(){
//        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
//            if snapshot.exists() {
//                var saved: Bool = false
//                if let dictionary = snapshot.value as? [String: AnyObject]{
//                    for fc in self.filteredContacts {
//                        if fc.id == snapshot.key {
//                            saved = true
//                        }
//                    }
//                    if !saved {
//                        var temp = dictionary
//                        var temp2 = [Contact]()
//                        temp["id"] = snapshot.key as AnyObject
//
//                        for c in self.contacts {
//
//                            if (c.email!.isEqual(dictionary["login"]! as! String)){
//                                print("saved")
//                                temp["email"] = dictionary["login"]
//                                temp["name"] = c.name as AnyObject?
//                                if #available(iOS 10.0, *) {
//                                    coreDataManager.shared.createContact(dictionary: temp)
//                                    self.filteredContacts = coreDataManager.shared.fetchContacts()
//                                    DispatchQueue.main.async {self.tableView.reloadData()}
//                                } else {}
//                            }
//
//                            if (c.phone!.isEqual(dictionary["login"]! as! String)){
//                                temp["phone"] = dictionary["login"]
//                                temp["name"] = c.name as AnyObject?
//                                if #available(iOS 10.0, *) {
//                                    coreDataManager.shared.createContact(dictionary: temp)
//                                    self.filteredContacts = coreDataManager.shared.fetchContacts()
//                                    DispatchQueue.main.async {self.tableView.reloadData()}
//                                } else {}
//                            }
//                        }
//                    }
//                }
//            }
//        }, withCancel: nil)
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewGroupChat") as! NewGroupChatViewController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            vc.chatsVC = self.chatsVC
            self.present(vc, animated: true, completion: nil)
        }else{
            dismiss(animated: true, completion: {
                tableView.deselectRow(at: indexPath, animated: true)
                let user = User()
                user.id = self.filteredContacts[indexPath.row].value(forKey: "id") as? String
                user.name = self.filteredContacts[indexPath.row].value(forKey: "name") as? String
                user.phone = self.filteredContacts[indexPath.row].value(forKey: "phone") as? String
                user.email = self.filteredContacts[indexPath.row].value(forKey: "email") as? NSString
                self.chatsVC?.showChatLogForUser(contact: user)
            })
        }
    }

}
