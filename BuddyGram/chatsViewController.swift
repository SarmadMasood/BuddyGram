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
import RNCryptor
import Photos

@available(iOS 10.0, *)
class chatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate{
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    private let key: String = "[v#7pH+?H5rJ/T<@9"
    let currentUserEmail = Auth.auth().currentUser?.email
    let currentUserPhone = Auth.auth().currentUser?.phoneNumber
    let currentUserUID = Auth.auth().currentUser?.uid
    
    let newChatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewChat") as! NewChatViewController
    
    @IBOutlet weak var tableView: UITableView!
    
    var contacts = [User]()
    
    @IBAction func addNewChat(_ sender: Any) {
        
        newChatVC.chatsVC = self
        newChatVC.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        newChatVC.navigationController?.navigationItem.title = "New Chat"
        present(newChatVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell",for: indexPath) as! chatsTableViewCell
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
        cell.chatImage.image = UIImage(named: "profile_default")

        if let group = coreDataManager.shared.fetchGroup(id: chatPartnerID){
            cell.name.text = group.value(forKey: "name") as! String
            cell.chatImage.image = UIImage(named: "GroupIcon")
            match = true
        }
        
        if !match {
            cell.name.text = chatPartnerID
        }
       
        return cell
    }
    
    var messagesDictionary = [String: Message]()
    var messages = [Message]()
    

    override func viewWillAppear(_ animated: Bool) {
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
        fetchContacts()
        fetchUsers()
        observeUserMessages()
        observeGroups()
        observeGroupMessages()
        if self.messages.count == 0 {
            self.messages.removeAll()
            self.tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
        guard let uid = Auth.auth().currentUser?.uid else {
                   return
               }
        let ref = Database.database().reference().child("userMessages").child(uid)
        let ref2 = Database.database().reference().child("messages")
        let ref3 = Database.database().reference().child("groupMessages")
        let ref4 = Database.database().reference().child("groups")
        ref.removeAllObservers()
        ref2.removeAllObservers()
        ref3.removeAllObservers()
        ref4.removeAllObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.hidesWhenStopped = true
        loadingView.isHidden = true
        loadingLabel.isHidden = true
      
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Arial Rounded MT Bold", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)]
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
    
    func showChatLogForUser(contact: User){
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
    
    func showChatLogForGroup(group: Group){
        let CLVC = storyboard?.instantiateViewController(withIdentifier: "GroupChatVC") as! GroupChatViewController
        CLVC.group = group
        CLVC.navigationItem.title = ""
        
        var button: UIBarButtonItem?
        let groupName = group.value(forKey: "name") as! String
        button = UIBarButtonItem(title: groupName, style: .done, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = button
        self.navigationController?.pushViewController(CLVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let message = messages[indexPath.row]
        let chatPartnerUUID = message.getChatPartnerUUID()
        if message.groupID != nil {
            let g = coreDataManager.shared.fetchGroup(id: chatPartnerUUID)
            showChatLogForGroup(group: g!)
        }else{
            let user = User()
            if let fetched = coreDataManager.shared.fetchContact(id: chatPartnerUUID) {
                user.id = fetched.value(forKey: "id") as? String
                user.name = fetched.value(forKey: "name") as? String
                user.phone = fetched.value(forKey: "phone") as? String
                user.email = fetched.value(forKey: "email") as? NSString
                showChatLogForUser(contact: user)
            }else {
                Database.database().reference().child("users").child(chatPartnerUUID).observe(.value) {
                    (snapshot) in
                    if snapshot.exists() {
                        let dictionary = snapshot.value as! [String: Any]
                        user.id = snapshot.key
                        user.name = dictionary["name"] as? String
                        user.phone = dictionary["login"] as? String
                        user.email = dictionary["login"] as? NSString
                        self.showChatLogForUser(contact: user)
                    }
                }
            }
        }
    }
    
    func observeGroups(){
        print("looking up user's groups")
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("users").child(uid).child("groups").observe(.childAdded) { (snapshot) in
            if snapshot.exists() {
                var saved: Bool = false
                let groupID = snapshot.value as! String
                if let group = coreDataManager.shared.fetchGroup(id: groupID){
                    saved = true
                }
                
                if !saved {
                    Database.database().reference().child("groups").child(groupID).observeSingleEvent(of: .value) { (groupSnapshot) in
                        print(groupSnapshot)
                        var dic = groupSnapshot.value as! [String: Any]
                        dic["id"] = groupID
                        coreDataManager.shared.createGroup(dictionary: dic)
                        self.observeGroupMessages()
                    }
                }else {print("group already saved")}
            }
        }
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
    
    func observeGroupMessages(){
        let groups = coreDataManager.shared.fetchGroups()
        for g in groups {
            let grpID = g.value(forKey: "id") as! String
            Database.database().reference().child("groupMessages").child(grpID).observe(.childAdded) { (snapshot) in
                let msgID = snapshot.key
                let msgRef = Database.database().reference().child("messages").child(msgID)
                msgRef.observeSingleEvent(of: .value) { (snapdoodle) in
                     if let dictionary = snapdoodle.value as? [String: AnyObject] {
                        let stamp = dictionary["timeStamp"] as! NSNumber
                        var saved = Bool()
                        if coreDataManager.shared.fetchMessage(timeStamp: stamp) != nil {
                            saved = true
                        }
                        
                        if !saved {
                            var temp = dictionary
                            if dictionary["fromID"] as! String == "msg1" && dictionary["fromUUID"] as! String != self.currentUserUID {
                                self.getUserName(id: dictionary["fromUUID"] as! String) { (name) in
                                    temp["text"] = name+"created this group." as AnyObject
                                }
                            }
                            coreDataManager.shared.createMessage(dictionary: temp)
                            self.messages = coreDataManager.shared.fetchMessages()

                            let message = self.messages.last
                            let partnerID = message!.getChatPartnerID()
                            self.messagesDictionary[partnerID] = message
                            self.messages = Array(self.messagesDictionary.values)
                            self.messages.sort (by: { (msg1, msg2) -> Bool in
                                return msg1.timeStamp!.intValue > msg2.timeStamp?.intValue as! Int
                            })
                            DispatchQueue.main.async {
                                   self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func saveFileToLocalStoreage(message: Message){
        let fileURL = message.fileURL
        let url = URL(string: fileURL!)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
              
            if error != nil {
                print(error ?? "")
                return
            }
                   
            let localURL = self.getDocumentsDirectory()?.appendingPathComponent(message.fileName!).appendingPathExtension(message.fileExt!)
            
            do {
                try data?.write(to: localURL!)
            }catch let errorMessage {
                print(errorMessage)
            }
            
            coreDataManager.shared.updateMessage(timeStamp: message.timeStamp!, key: "fileURL", value: localURL!.absoluteString)
        }).resume()
    }
    
    func saveMediaToLocalStoreage(message: Message,downloadURL: String,valueToChange: String,ext: String){
        let url = URL(string: downloadURL)
        
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                                                
                if error != nil {
                    print(error ?? "")
                    return
                }
                                                              
            let localURL = self.getDocumentsDirectory()?.appendingPathComponent(UUID().uuidString).appendingPathExtension(ext)
                                                       
        do {
            let file = self.decrypt(data: data!, key: self.key)
            try file?.write(to: localURL!)
        }catch let errorMessage {
            print(errorMessage)
        }
                                                       
            coreDataManager.shared.updateMessage(timeStamp: message.timeStamp!, key: valueToChange, value: localURL!.absoluteString)
            
        }).resume()
    }
    
    func observeMessageUsingID(msgID: String,toID: String){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let msgRef = Database.database().reference().child("messages").child(msgID)
            msgRef.observeSingleEvent(of: .value) { (snapdoodle) in
            if let dictionary = snapdoodle.value as? [String: AnyObject] {
                let stamp = dictionary["timeStamp"] as! NSNumber
                var saved = Bool()
                if coreDataManager.shared.fetchMessage(timeStamp: stamp) != nil {
                    saved = true
                }
                
                if !saved {
                    var temp = dictionary
                    if dictionary["imageURL"]==nil && dictionary["fileURL"]==nil && dictionary["audioURL"]==nil && dictionary["videoURL"]==nil {
                        let text = temp["text"] as! String
                        let data: Data = Data(base64Encoded: text)!
                        let decryptedData = self.decrypt(data: data, key: self.key)
                        let txt = String(data: decryptedData!, encoding: .utf8)
                        
                        temp["text"] = txt as AnyObject?
                        coreDataManager.shared.createMessage(dictionary: temp)
                        }else{
                            coreDataManager.shared.createMessage(dictionary: dictionary)
                        }
                        self.messages = coreDataManager.shared.fetchMessages()
                    
                        let message = self.messages.last
                        if message?.fileURL != nil{
                             self.saveFileToLocalStoreage(message: message!)
                         }
                         
                         if let imageURL = message?.imageURL {
                             self.saveMediaToLocalStoreage(message: message!, downloadURL: imageURL, valueToChange: "imageURL", ext: "jpeg")
                         }
                         
                         if let videoURL = message?.videoURL {
                             self.saveMediaToLocalStoreage(message: message!, downloadURL: videoURL, valueToChange: "videoURL", ext: "mov")
                         }
                         
                         if let audioURL = message?.audioURL {
                             self.saveMediaToLocalStoreage(message: message!, downloadURL: audioURL, valueToChange: "audioURL", ext: "m4a")
                         }
                         
                         if message?.groupID == nil {
                             temp["isSeen"] = "true" as AnyObject
                             msgRef.updateChildValues(temp)
                             let seenRef = Database.database().reference().child("seenMessages").child(message!.fromUUID!).child(uid)
                            seenRef.updateChildValues([msgRef.key!: ""])
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
                    }
                }
            }
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
                    self.observeMessageUsingID(msgID: msgID,toID: uid)
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
                            let c = User()
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
    
    func fetchUsers(){
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if snapshot.exists() {
                var saved: Bool = false
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    if let filteredContact = coreDataManager.shared.fetchContact(id: snapshot.key) {
                       saved = true
                    }
            
                    if !saved {
                        var temp = dictionary
                        temp["id"] = snapshot.key as AnyObject
                        
                        for c in self.contacts {
                            
                            if (c.email!.isEqual(dictionary["login"]! as! String)){

                                temp["email"] = dictionary["login"]
                                temp["name"] = c.name as AnyObject?
                                coreDataManager.shared.createContact(dictionary: temp)
                            }
                           
                            if (c.phone!.isEqual(dictionary["login"]! as! String)){
                                temp["phone"] = dictionary["login"]
                                temp["name"] = c.name as AnyObject?
                                coreDataManager.shared.createContact(dictionary: temp)
                            }
                        }
                    }
                }
            }
        }, withCancel: nil)
    }
    
    @IBAction func cancelToChats(_ segue: UIStoryboardSegue) {

    }
    
    func encrypt(data: Data, key: String) -> Data{
           let encryptedData = RNCryptor.encrypt(data: data, withPassword: key)
           return encryptedData
       }
       
       func decrypt(data: Data, key: String) -> Data? {
           do{
               let decryptedData = try RNCryptor.decrypt(data: data, withPassword: key)
               return decryptedData
           } catch {
               return nil
           }
       }
}

