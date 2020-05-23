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
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    let newChatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewChat") as! NewChatViewController
    
    @IBOutlet weak var tableView: UITableView!
    
//    override func viewWillAppear(_ animated: Bool) {
//        tableView.reloadData()
//    }
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
    

    override func viewWillAppear(_ animated: Bool) {
         if #available(iOS 10.0, *) {
            self.messages = coreDataManager.shared.fetchMessages()
            for message in messages {
                let partnerID = message.getChatPartnerID()
                                                                  
                self.messagesDictionary[partnerID] = message
                self.messages = Array(self.messagesDictionary.values)
                self.messages.sort (by: { (msg1, msg2) -> Bool in
                    return msg1.timeStamp!.intValue > msg2.timeStamp?.intValue as! Int
                })
                self.tableView.reloadData()
            }
            
        } else {
        // Fallback on earlier versions
        }
       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
        guard let uid = Auth.auth().currentUser?.uid else {
                   return
               }
        
        let ref = Database.database().reference().child("userMessages").child(uid)
        let ref2 = Database.database().reference().child("messages")
        ref.removeAllObservers()
        ref2.removeAllObservers()
        NotificationCenter.default.removeObserver(self)
        if self.messages.last?.text == "New Messages" {
            self.messages.removeLast()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.hidesWhenStopped = true
        loadingView.isHidden = true
        loadingLabel.isHidden = true
        
        observeUserMessages()
        fetchContacts()
        newChatVC.fetchUsers()
      
        if #available(iOS 10.0, *) {
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Arial Rounded MT Bold", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)]
        } else {}
    }
    
    func getDocumentsDirectory() -> URL?
    {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create: false)
            
            return documentDirectory
        }
        catch {
            print(error)
        }
        return nil
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
            let contactID = snapshot.key
            Database.database().reference().child("userMessages").child(uid).child(contactID).observe(.childAdded) { (snap) in
                if snap.exists() {
                    let msgID = snap.key
                    let msgRef = Database.database().reference().child("messages").child(msgID)
                    msgRef.observeSingleEvent(of: .value) { (snapdoodle) in
                         if let dictionary = snapdoodle.value as? [String: AnyObject] {
                            
                        if dictionary["toUUID"] as! String == uid && dictionary["isSeen"] as! String == "false"{
                            var temp = dictionary
                                if #available(iOS 10.0, *) {
                                     coreDataManager.shared.createMessage(dictionary: dictionary)
                                    
                                    self.messages = coreDataManager.shared.fetchMessages()
                    
                                    let message = self.messages.last
                                    
                                    if message!.isSeen == "false" {
                                        if let fileURL = message?.fileURL {
                                            let url = URL(string: fileURL)
                                            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                                                  
                                                       if error != nil {
                                                           print(error ?? "")
                                                           return
                                                       }
                                                       
                                                let localURL = self.getDocumentsDirectory()?.appendingPathComponent(message!.fileName!).appendingPathExtension(message!.fileExt!)
                                                
                                                do {
                                                    try data?.write(to: localURL!)
                                                }catch let errorMessage {
                                                    print(errorMessage)
                                                }
                                                
                                                coreDataManager.shared.updateMessage(timeStamp: message!.timeStamp!, key: "fileURL", value: localURL!.absoluteString)
                                            
                                                       
                                                   }).resume()
                                        }
                                        temp["isSeen"] = "true" as AnyObject
                                        msgRef.updateChildValues(temp)
                                        let seenRef = Database.database().reference().child("seenMessages").child(message!.fromUUID!).child(uid)
                                        seenRef.updateChildValues([msgRef.key as! String: ""])
                                    }
                                    
                                    let partnerID = message!.getChatPartnerID()
                                    self.messagesDictionary[partnerID] = message
                                    self.messages = Array(self.messagesDictionary.values)
                                    self.messages.sort (by: { (msg1, msg2) -> Bool in
                                        return msg1.timeStamp!.intValue > msg2.timeStamp?.intValue as! Int
                                    })
                                    DispatchQueue.main.async {
                                          self.tableView.reloadData()
                                   }
                    
                    
                                 } else {
                                     // Fallback on earlier versions
                                 }
                            }
                        
                    }
                }

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
        let chatPartnerUUID = messages[indexPath.row].getChatPartnerUUID()
        let chatPartnerID = messages[indexPath.row].getChatPartnerID()
        var user = Contact()
        user.id = chatPartnerUUID
        let ref = Database.database().reference().child("users").child(chatPartnerUUID)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                user.name = dictionary["name"] as! String
                user.email = dictionary["login"] as! NSString
                user.phone = dictionary["login"] as! String
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

