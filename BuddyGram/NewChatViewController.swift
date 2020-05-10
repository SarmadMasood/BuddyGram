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

class NewChatViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate{
    
    var chatsVC: chatsViewController?
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
            as! ContactTableViewCell
        cell.nameLabel.text = filteredContacts[indexPath.row].name
        return cell
    }
    
    
    var contacts = [Contact]()
    var filteredContacts = [Contact]()

    override func viewDidLoad() {
        super.viewDidLoad()
        if filteredContacts.isEmpty {
            contacts.removeAll()
            filteredContacts.removeAll()
            fetchContacts()
            fetchUsersWithReload()
        }
        
        // Do any additional setup after loading the view.
    }
    
    func fetchContacts()  {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let err = error{
                print("Failed to access contacts",err)
                return
            }
            if granted{
                print("Access Granted to contacts.")
                let keys = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactEmailAddressesKey,CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopNumeratingPointer) in
                        var c = Contact()
                        c.name = contact.givenName
                        c.name?.append(" ")
                        c.name?.append(contact.familyName)
                        
                        c.phone = contact.phoneNumbers.first?.value.stringValue ?? ""
                        let phone = String(c.phone!.filter { !" \n\t\r".contains($0) })
                        c.phone = phone
                        
                        c.email = contact.emailAddresses.first?.value ?? ""
                        self.contacts.append(c)
                        })
                    
                } catch let err {
                    print(err)
                }
            
        }
    }
        
}
    
    func fetchUsersWithReload(){
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if snapshot.exists() {
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    for c in self.contacts {
                        if (c.email!.isEqual(dictionary["login"]! as! String)){
                            c.id = snapshot.key
                            self.filteredContacts.append(c)
                            self.tableView.reloadData()
                        }
                      //  print(c.phone)
                        if (c.phone!.isEqual(dictionary["login"]! as! String)){
                            c.id = snapshot.key
                            self.filteredContacts.append(c)
                            DispatchQueue.main.async {self.tableView.reloadData()}
                        }
                    }
                }
            }
        }, withCancel: nil)
    }
    
    func fetchUsers(){
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if snapshot.exists() {
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    for c in self.contacts {
                        if (c.email!.isEqual(dictionary["login"]! as! String)){
                            c.id = snapshot.key
                            self.filteredContacts.append(c)
                        }
                       // print(c.phone)
                        if (c.phone!.isEqual(dictionary["login"]! as! String)){
                            c.id = snapshot.key
                            self.filteredContacts.append(c)
                        }
                    }
                }
            }
        }, withCancel: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        dismiss(animated: true, completion: {
            tableView.deselectRow(at: indexPath, animated: true)
            self.chatsVC?.showChatLogForUser(contact: self.filteredContacts[indexPath.row])
        })
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
