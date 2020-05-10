//
//  chatsViewController.swift
//  BuddyGram
//
//  Created by Mac OSX on 4/23/20.
//  Copyright © 2020 Mac OSX. All rights reserved.
//

import UIKit
import Firebase
import Contacts

class chatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate{
    let newChatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewChat") as! NewChatViewController
    
    @IBOutlet weak var tableView: UITableView!
   // var contact: Contact?
    var contacts = [Contact]()
    
    @IBAction func addNewChat(_ sender: Any) {
        
        newChatVC.chatsVC = self
        newChatVC.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        self.present(newChatVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell",for: indexPath) as? chatsTableViewCell else{
            return UITableViewCell()
        }
        
      let chatPartnerID = messages[indexPath.row].getChatPartnerID()
        
        cell.latestMsgLabel.text = messages[indexPath.row].text
        if let seconds = messages[indexPath.row].timeStamp?.doubleValue {
            let date = Date(timeIntervalSince1970: seconds)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            cell.dateLabel.text = formatter.string(from: date)
        }
        var match: Bool = false
        for c in contacts {
            if (c.email?.isEqual(to: chatPartnerID))!  || c.phone!.isEqual(chatPartnerID){
                cell.name.text = c.name
                match = true
            }

        }
        
        if !match {
            cell.name.text = chatPartnerID
        }
       
        return cell
    }
    
    var messagesDictionary = [String: Message]()
    var messages = [Message]()
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchContacts()
        newChatVC.fetchUsers()
        observeUserMessages()
      
        if #available(iOS 10.0, *) {
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Arial Rounded MT Bold", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)]
        } else {
            // Fallback on earlier versions
        }
        
        // Do any additional setup after loading the view.
    }
    
    func showChatLogForUser(contact: Contact){
        let CLVC = storyboard?.instantiateViewController(withIdentifier: "chatLog") as! ChatLogViewController
        CLVC.contact = contact
        CLVC.navigationItem.title = ""
        var button: UIBarButtonItem?
        if contact.name != "" {
            button = UIBarButtonItem(title: contact.name, style: .done, target: nil, action: nil)
        }else if contact.phone != ""{
            button = UIBarButtonItem(title: contact.phone, style: .done, target: nil, action: nil)
        }else{
            button = UIBarButtonItem(title: contact.email as String?, style: .done, target: nil, action: nil)
        }
        
        self.navigationItem.backBarButtonItem = button
        self.navigationController?.pushViewController(CLVC, animated: true)
    }
    
    func observeUserMessages(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("userMessages").child(uid)
        ref.observe(.childAdded) { (snapshot) in
            let msgID = snapshot.key
            let msgRef = Database.database().reference().child("messages").child(msgID)
            msgRef.observeSingleEvent(of: .value) { (snap) in
                 if let dictionary = snap.value as? [String: AnyObject] {
                                   //print(snapshot)
                let message = Message(dictionary: dictionary)
                    let partnerID = message.getChatPartnerID()
                                    
                    self.messagesDictionary[partnerID] = message
                    self.messages = Array(self.messagesDictionary.values)
                    self.messages.sort (by: { (msg1, msg2) -> Bool in
                                        
                        return msg1.timeStamp!.intValue > msg2.timeStamp?.intValue as! Int
                    })
                    DispatchQueue.main.async {self.tableView.reloadData()}
                }
            }
        }
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chatPartnerID = messages[indexPath.row].getChatPartnerID()
        var user = Contact()
        let ref = Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let login = dictionary["login"] as! String
                if login.isEqual(chatPartnerID){
                    user.id = snapshot.key
                    user.name = dictionary["name"] as! String
                    user.email = dictionary["login"] as! NSString
                    user.phone = dictionary["login"] as! String
                }
            }
        }
        
        for c in contacts {
             if (c.email?.isEqual(to: chatPartnerID))!  || c.phone!.isEqual(chatPartnerID){
                user.name = c.name
            }
        }
        showChatLogForUser(contact: user)
    }
    
    
    @IBAction func cancelToChats(_ segue: UIStoryboardSegue) {

    }

}
