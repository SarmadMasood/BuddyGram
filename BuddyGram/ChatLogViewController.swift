//
//  ChatLogViewController.swift
//  BuddyGram
//
//  Created by Mac OSX on 4/27/20.
//  Copyright © 2020 Mac OSX. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation
import AVKit
import RNCryptor
import Photos

let imageCache = NSCache<NSString, UIImage>()

@available(iOS 10.0, *)
class ChatLogViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIDocumentPickerDelegate,UIDocumentInteractionControllerDelegate{
    
    private let key: String = "[v#7pH+?H5rJ/T<@9"
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var keyBoardheight: CGFloat!
    
    @IBOutlet weak var recordTimer: UILabel!
    
    @IBOutlet weak var audioMessageButton: UIButton!
    @IBOutlet weak var attachButton: UIButton!
    var selectedIndexPath: IndexPath!
    var soundRecorder : AVAudioRecorder!
    var latestTimeStamp: NSNumber?
    var contact: User?
    var messages = [Message]()
    let currentUserEmail = Auth.auth().currentUser?.email
    let currentUserPhone = Auth.auth().currentUser?.phoneNumber
    let currentUserUID = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var collectionView: UICollectionView!
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
        }
    
    func playVideo(message: Message){
        if let videoURL = message.videoURL {
            let url = URL(string: videoURL)
            let player = AVPlayer(url: url!)
            let controller = AVPlayerViewController()
            controller.player=player

            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill;

            controller.showsPlaybackControls = false
            controller.view.frame = self.view.frame
            let directions: [UISwipeGestureRecognizer.Direction] = [.right, .left, .up, .down]
            for direction in directions {
                let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(gesture:)))
                gesture.direction = direction
                controller.view.addGestureRecognizer(gesture)
                controller.showsPlaybackControls = true
            }
                              
            self.present(controller, animated: true, completion: nil)
            player.play()
            player.actionAtItemEnd = .none
        }
    }
    
    func showImage(message: Message){
        if let imageURL = message.imageURL  {
            let vc = storyboard?.instantiateViewController(withIdentifier: "imageDetail") as! ZoomedViewController
            if let cachedImage = imageCache.object(forKey: imageURL as NSString) {
                    vc.image = cachedImage
                }
                self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @objc func handleSwipe(gesture: UISwipeGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
        
        
        func savetoDocumentsFolder(data: Data,message: Message){
            print("saving...")
            do {
                let fileURL = self.getDocumentsDirectory()?.appendingPathComponent(message.fileName!).appendingPathExtension(message.fileExt!)
                try data.write(to: fileURL!)
            } catch {
                print(error)
            }
        }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    let docPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeItem)], in: .import)
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.replyHint.isHidden = true
            self.replyName.isHidden = true
            self.replyText.isHidden = true
            self.replyImage.isHidden = true
            self.replyCancelButton.isHidden = true
            self.replyViewHeight.constant = 49
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        let filename = urls.first!.lastPathComponent
        let ext = urls.first!.pathExtension
        let url = urls.first
        
        var toID: String?
        if self.contact?.phone != nil {
            toID = self.contact?.phone as String?
        }else{
            toID = self.contact?.email as String?
        }
        
        var fromID:  String?
        if self.currentUserEmail != nil {
            fromID = self.currentUserEmail
        }else {
            fromID = self.currentUserPhone
        }
        let timeStamp: NSNumber = NSNumber(value: NSDate().timeIntervalSince1970)
        
        var values = ["isSeen": "false","replyTimeStamp": replyTimeStamp,"ext": ext,"fileURL": url!.absoluteString,"filename": filename,"text": "File","toID": toID, "fromID": fromID, "timeStamp": timeStamp, "fromUUID": self.currentUserUID, "toUUID": self.contact?.id] as [String : Any]
        
        coreDataManager.shared.createMessage(dictionary: values)
        let temp = coreDataManager.shared.fetchSortedMessages()
        self.messages = temp.filter({( message : Message) -> Bool in
            return (message.toUUID==contact?.id || message.fromUUID == contact?.id) && message.groupID == nil
        })
        self.collectionView.reloadData()
        scrollToLastMessage()
        
        let ref = Storage.storage().reference().child("files").child(filename)
        do{
            
            ref.putFile(from: url!, metadata: nil) { (metadata, err) in
                ref.downloadURL { (downloadURL, error) in

                    values["fileURL"] = downloadURL?.absoluteString
                    self.uploadMsgWithValues(values: values)
                }
            }
        }
        catch{
            print("failed to upload file")
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.imagePickerController.dismiss(animated: true) {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.replyTimeStamp = 0
                self.replyHint.isHidden = true
                self.replyName.isHidden = true
                self.replyText.isHidden = true
                self.replyImage.isHidden = true
                self.replyCancelButton.isHidden = true
                self.replyViewHeight.constant = 49
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.replyTimeStamp = 0
            self.replyHint.isHidden = true
            self.replyName.isHidden = true
            self.replyText.isHidden = true
            self.replyImage.isHidden = true
            self.replyCancelButton.isHidden = true
            self.replyViewHeight.constant = 49
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    let imagePickerController = UIImagePickerController()
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.replyHint.isHidden = true
            self.replyName.isHidden = true
            self.replyText.isHidden = true
            self.replyImage.isHidden = true
            self.replyCancelButton.isHidden = true
            self.replyViewHeight.constant = 49
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let videoURL = (info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)]) as? URL{
            
            uploadVideoToFirebase(videoURL: videoURL)
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        let image = (info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage)!
        
        uploadImageToFirebase(image: image)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadImageToFirebase(image: UIImage){
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.replyHint.isHidden = true
            self.replyName.isHidden = true
            self.replyText.isHidden = true
            self.replyImage.isHidden = true
            self.replyCancelButton.isHidden = true
            self.replyViewHeight.constant = 49
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        let imageName = UUID().uuidString
        var toID: String?
        if self.contact?.phone != nil {
            toID = self.contact?.phone
        }else{
            toID = self.contact?.email as String?
        }
        
        var fromID:  String?
        if self.currentUserEmail != nil {
            fromID = self.currentUserEmail
        }else {
            fromID = self.currentUserPhone
        }
        let timeStamp: NSNumber = NSNumber(value: NSDate().timeIntervalSince1970)
        
        let url = getDocumentsDirectory()?.appendingPathComponent(imageName).appendingPathExtension("jpeg")
        let imageData = image.jpegData(compressionQuality: 0.2)
        do {
            try imageData?.write(to: url!)
        } catch let error {
            print(error)
        }
        var values = ["isSeen": "false","replyTimeStamp": replyTimeStamp,"text": "Photo","imageURL": url?.absoluteString, "toID": toID, "fromID": fromID, "timeStamp": timeStamp,"imageWidth": image.size.width,"imageHeight": image.size.height, "fromUUID": self.currentUserUID, "toUUID": self.contact?.id] as [String : Any]
        
        if #available(iOS 10.0, *) {
            coreDataManager.shared.createMessage(dictionary: values)
            let temp = coreDataManager.shared.fetchSortedMessages()
            self.messages = temp.filter({( message : Message) -> Bool in
                return (message.toUUID==contact?.id || message.fromUUID == contact?.id) && message.groupID == nil
            })
            self.collectionView.reloadData()
            scrollToLastMessage()
        } else {}
        
        let ref = Storage.storage().reference().child("messageImages").child(imageName)
        
        let uploadData = self.encrypt(data: imageData!, key: key)
        
        if uploadData != nil {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("Failed to upload image:", error!)
                    return
                }
                
                ref.downloadURL(completion: { (downloadURL, err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    values["imageURL"] = downloadURL?.absoluteString
                    self.uploadMsgWithValues(values: values)
                })
                
            })
        }
    }
    
    func uploadVideoToFirebase(videoURL: URL){
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.replyHint.isHidden = true
            self.replyName.isHidden = true
            self.replyText.isHidden = true
            self.replyImage.isHidden = true
            self.replyCancelButton.isHidden = true
            self.replyViewHeight.constant = 49
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        var toID: String?
               if self.contact?.phone != nil {
                   toID = self.contact?.phone
               }else{
                   toID = self.contact?.email as String?
               }
               
               var fromID:  String?
               if self.currentUserEmail != nil {
                   fromID = self.currentUserEmail
               }else {
                   fromID = self.currentUserPhone
               }
               let timeStamp: NSNumber = NSNumber(value: NSDate().timeIntervalSince1970)
               let imageName = NSUUID().uuidString
            let image = self.thumbnailForVideo(videoURL: videoURL)
        let imageURL = getDocumentsDirectory()?.appendingPathComponent(imageName).appendingPathExtension("jpeg")
        var imageData = image!.jpegData(compressionQuality: 0.2)
        do {
            try imageData?.write(to: imageURL!)
        } catch let error {
            print(error)
        }
        
        var values = ["isSeen": "false","replyTimeStamp": replyTimeStamp,"text": "Video","videoURL": videoURL.absoluteString, "toID": toID, "fromID": fromID, "timeStamp": timeStamp,"imageHeight": image!.size.height,"imageWidth": image!.size.width,"imageURL": imageURL?.absoluteString, "fromUUID": self.currentUserUID, "toUUID": self.contact?.id] as [String : Any]
        
        coreDataManager.shared.createMessage(dictionary: values)
         let temp = coreDataManager.shared.fetchSortedMessages()
         self.messages = temp.filter({( message : Message) -> Bool in
             return (message.toUUID==contact?.id || message.fromUUID == contact?.id) && message.groupID == nil
         })
         self.collectionView.reloadData()
        scrollToLastMessage()
        
        let ref = Storage.storage().reference().child("messageImages").child(imageName)
        let uploadData = self.encrypt(data: imageData!, key: key)
        
        
        if uploadData != nil {
            do{
                let video = try Data(contentsOf: videoURL)
                ref.putData(uploadData, metadata: nil) { (metaData, error) in
                            ref.downloadURL { (imageDownloadURL, err) in
                                    let filename = NSUUID().uuidString + ".mov"
                                              
                                    let ref = Storage.storage().reference().child("messageVideos").child(filename)
                                       
                                    let videoData = self.encrypt(data: video, key: self.key)
                                    let upload =  ref.putData(videoData, metadata: nil) { (metadata, err) in
                                    ref.downloadURL { (vidDownloadURL, err) in
                                    values["imageURL"] = imageDownloadURL?.absoluteString
                                    values["videoURL"] = vidDownloadURL?.absoluteString
                                    self.uploadMsgWithValues(values: values)
                                }
                            }
                            upload.observe(.progress) { (Snapshot) in
                            print(Snapshot.progress?.completedUnitCount)
                            }
                        }
                    }
            }catch{
                print("error video failed")
            }
        }
    }
    
    func thumbnailForVideo(videoURL: URL) -> UIImage? {
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let thumbnail = try imageGenerator.copyCGImage(at: CMTime(value: 1, timescale: 60), actualTime: nil)
             return UIImage(cgImage: thumbnail)
        }
        catch let err {
            print(err)
        }
        
        return nil
    }
    @IBOutlet weak var replyViewHeight: NSLayoutConstraint!
    @IBOutlet weak var replyViewBottom: NSLayoutConstraint!
    @IBOutlet weak var replyHint: UIView!
    @IBOutlet weak var replyName: UILabel!
    @IBOutlet weak var replyText: UILabel!
    @IBOutlet weak var replyImage: UIImageView!
    @IBOutlet weak var replyCancelButton: UIButton!
    @IBAction func cancelReply(_ sender: Any) {
        self.replyTimeStamp = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.replyHint.isHidden = true
            self.replyName.isHidden = true
            self.replyText.isHidden = true
            self.replyImage.isHidden = true
            self.replyCancelButton.isHidden = true
            self.replyViewHeight.constant = 49
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    var replyTimeStamp: NSNumber = 0
    
    func presentReplyAction(message: Message){
        
        self.msgInputField.resignFirstResponder()
        self.replyTimeStamp = message.timeStamp!
        self.replyHint.isHidden = true
        self.replyName.isHidden = true
        self.replyText.isHidden = true
        self.replyImage.isHidden = true
        self.replyCancelButton.isHidden = true
        self.replyViewHeight.constant = 49
        
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            menu.view.tintColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
                 
        let cancel = UIAlertAction(title: "Cancel", style: .cancel){(result: UIAlertAction) in
            self.replyTimeStamp = 0
        }
        
        let replyAction = UIAlertAction(title: "Reply", style: .default){(result: UIAlertAction) in
            
                self.msgInputField.select(self)
               // self.isReply = true
                self.replyText.text = message.text
                
                if message.fromUUID == self.currentUserUID {
                    self.replyName.text = "You"
                }else if message.fromUUID == self.contact!.id {
                    self.replyName.text = self.contact?.name
                }
                
                if let imageURL = message.imageURL {
                    self.replyImage.image = imageCache.object(forKey: imageURL as NSString)
                }
                
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.replyHint.isHidden = false
                    self.replyName.isHidden = false
                    self.replyText.isHidden = false
                    self.replyImage.isHidden = false
                    self.replyCancelButton.isHidden = false
                    self.replyViewHeight.constant = 100
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .default){(result: UIAlertAction) in
            coreDataManager.shared.deleteMessage(timeStamp: message.timeStamp!)
            var temp = [Message]()
            temp = coreDataManager.shared.fetchSortedMessages()
            self.messages = temp.filter({( message : Message) -> Bool in
                return (message.toUUID==self.contact?.id || message.fromUUID == self.contact?.id) && message.groupID == nil
            })
            self.collectionView.reloadData()
        }
        
        let copyAction = UIAlertAction(title: "Copy", style: .default){(result: UIAlertAction) in
         
            UIPasteboard.general.string = message.text
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default){(result: UIAlertAction) in
            if let url = message.videoURL {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(string: url)!)
                }) { saved, error in
                    if saved {
                        let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            
            if message.imageURL != nil && message.videoURL == nil {
                let url = URL(string: message.imageURL!)
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url!)
                }) { saved, error in
                    if saved {
                        let alertController = UIAlertController(title: "Your image was successfully saved", message: nil, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            
        }
        
        menu.addAction(replyAction)
        
        if message.text == "Photo" || message.text == "Video"{
            menu.addAction(saveAction)
        }else{
            menu.addAction(copyAction)
        }
        
        menu.addAction(deleteAction)
        menu.addAction(cancel)
        self.present(menu, animated: true, completion: nil)
    }
       
       @IBAction func attachFile(_ sender: Any) {
        self.imagePickerController.mediaTypes = [String(kUTTypeImage), String(kUTTypeMovie)]
           self.imagePickerController.view.tintColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
           
           let menu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
           menu.view.tintColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
           
           let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
           
           let galleryAction = UIAlertAction(title: "Photo Library", style: .default){(result: UIAlertAction) in
            
               self.imagePickerController.sourceType = .photoLibrary
               self.imagePickerController.modalPresentationStyle = .popover
               self.present(self.imagePickerController, animated: true, completion: nil)
           }
           
           let cameraAction = UIAlertAction(title: "Camera", style: .default){(result: UIAlertAction) in
               
               self.imagePickerController.sourceType = .camera
               self.imagePickerController.modalPresentationStyle = .popover
               self.present(self.imagePickerController, animated: true, completion: nil)
           }
        
            let docAction = UIAlertAction(title: "Document", style: .default){(result: UIAlertAction) in
                self.docPicker.modalPresentationStyle = .popover
                self.present(self.docPicker, animated: true, completion: nil)
            }
        
            let locAction = UIAlertAction(title: "Location", style: .default){(result: UIAlertAction) in
                
                
            }
        
            let contactAction = UIAlertAction(title: "Contact", style: .default){(result: UIAlertAction) in
                
              
            }
        
        
        if let icon = UIImage(named: "Camera1")?.imageWithSize(scaledToSize: CGSize(width: 25, height: 20)) {
            cameraAction.setValue(icon, forKey: "image")
        }
        
        if let icon2 = UIImage(named: "Gallery1")?.imageWithSize(scaledToSize: CGSize(width: 25, height: 21)) {
            galleryAction.setValue(icon2, forKey: "image")
        }
        
        if let icon3 = UIImage(named: "Document1")?.imageWithSize(scaledToSize: CGSize(width: 22, height: 25)) {
            docAction.setValue(icon3, forKey: "image")
        }
        
        if let icon4 = UIImage(named: "Location1")?.imageWithSize(scaledToSize: CGSize(width: 28, height: 30)) {
            locAction.setValue(icon4, forKey: "image")
        }
        
        if let icon5 = UIImage(named: "Contact1")?.imageWithSize(scaledToSize: CGSize(width: 28, height: 28)) {
            contactAction.setValue(icon5, forKey: "image")
        }
        
        menu.addAction(cameraAction)
        menu.addAction(galleryAction)
        menu.addAction(docAction)
        menu.addAction(locAction)
        menu.addAction(contactAction)
        menu.addAction(cancel)
        self.present(menu, animated: true, completion: nil)
    }
        
    var playButton = UIButton()
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let message = messages[indexPath.item]
            
            if message.replyTimeStamp != 0 {
                
                if message.audioURL != nil {
                    let audioReplyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "audioReplyBubble", for: indexPath) as! ReplyBubbleAudioCell
                    setupAudioReplyCell(audioReplyCell, message: message)
                    audioReplyCell.message = message
                    audioReplyCell.chatLogVC = self
                    
                    if message.isSeen == "true" {
                        audioReplyCell.readReceipt.image = UIImage(named: "seen")
                    }else{
                        audioReplyCell.readReceipt.image = UIImage(named: "delivered")
                    }
                    
                    return audioReplyCell
                }
                
                if message.fileURL != nil {
                    let fileReplyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "fileReplyBubble", for: indexPath) as! ReplyBubbleFileCell
                    
                        setupReplyFileCell(fileReplyCell, message: message)
                        
                        if message.isSeen == "true" {
                            fileReplyCell.readReceipt.image = UIImage(named: "seen")
                        }else{
                            fileReplyCell.readReceipt.image = UIImage(named: "delivered")
                        }
                        
                        fileReplyCell.message = message
                        fileReplyCell.chatLogVC = self
                        
                        return fileReplyCell
                }
                
                let replyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReplyBubble", for: indexPath) as! ReplyBubbleCell
                setupReplyCell(replyCell, message: message)
                replyCell.message = message
                replyCell.chatLogVC = self
                
                if message.isSeen == "true" {
                    replyCell.readReceipt.image = UIImage(named: "seen")
                }else{
                    replyCell.readReceipt.image = UIImage(named: "delivered")
                }
                
                return replyCell
            }
            
            if message.audioURL != nil {
                let audioCell = collectionView.dequeueReusableCell(withReuseIdentifier: "audioChatBubble", for: indexPath) as! ChatBubbleAudioCell
                setupAudioCell(audioCell, message: message)
                audioCell.message = message
                audioCell.chatLogVC = self
                
                if message.isSeen == "true" {
                    audioCell.readReceipt.image = UIImage(named: "seen")
                }else{
                    audioCell.readReceipt.image = UIImage(named: "delivered")
                }
                
                return audioCell
            }
            
            if message.fileURL != nil {
                let fileCell = collectionView.dequeueReusableCell(withReuseIdentifier: "fileChatBubble", for: indexPath) as! chatBubbleFileCell
            
                setupFileCell(fileCell, message: message)
                
                if message.isSeen == "true" {
                    fileCell.readReceipt.image = UIImage(named: "seen")
                }else{
                    fileCell.readReceipt.image = UIImage(named: "delivered")
                }
                
                fileCell.message = message
                fileCell.chatLogVC = self
                
                return fileCell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatBubble", for: indexPath) as! chatBubbleCell
            
            cell.chatLogVC = self
            cell.message = message
        
            setupCell(cell, message: message)
            
            if message.isSeen == "true" {
                cell.readReceipt.image = UIImage(named: "seen")
            }else{
                cell.readReceipt.image = UIImage(named: "delivered")
            }
            
            return cell
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
    
  fileprivate func setupAudioCell(_ cell: ChatBubbleAudioCell, message: Message) {
      if message.fromID == currentUserEmail ||  message.fromID == currentUserPhone{
          //outgoing blue
          cell.bubbleView.backgroundColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
          cell.timerLabel.textColor = UIColor.white
          cell.msgTime.textColor = UIColor.white
          cell.slider.tintColor = UIColor.white
        cell.readReceipt.isHidden = false
        cell.readReceiptWidth!.constant = 19
        cell.slider.maximumTrackTintColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        
          cell.bubbleRightAnchor?.isActive = true
          cell.bubbleLeftAnchor?.isActive = false
          
      } else {
          //incoming gray
          cell.bubbleView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
          cell.timerLabel.textColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
          cell.msgTime.textColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
        cell.slider.tintColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
        cell.slider.maximumTrackTintColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
        cell.readReceipt.isHidden = true
        cell.readReceiptWidth!.constant = 0
          
          cell.bubbleRightAnchor?.isActive = false
          cell.bubbleLeftAnchor?.isActive = true
      }
      
    if let seconds = message.timeStamp?.doubleValue {
        let date = Date(timeIntervalSince1970: seconds)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        cell.msgTime.text = formatter.string(from: date)
        
        if let duration = message.audioDuration {
            var currentMins = Int(duration) / 60
            var currentSec = Int(duration) % 60
            var timer = String(format: "%02i:%02i", currentMins,currentSec)

            cell.timerLabel.text = timer
        }
    }
    
    cell.slider.setThumbImage(makeCircleWith(size: CGSize(width: 15, height: 15), backgroundColor: UIColor.brown), for: .normal)
    cell.slider.setThumbImage(makeCircleWith(size: CGSize(width: 15, height: 15), backgroundColor: UIColor.brown), for: .highlighted)
  }
    
    fileprivate func setupAudioReplyCell(_ cell: ReplyBubbleAudioCell, message: Message) {
        if message.fromID == currentUserEmail ||  message.fromID == currentUserPhone{
            //outgoing blue
            cell.bubbleView.backgroundColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
            cell.timerLabel.textColor = UIColor.white
            cell.msgTime.textColor = UIColor.white
            cell.slider.tintColor = UIColor.white
          cell.readReceipt.isHidden = false
          cell.readReceiptWidth!.constant = 19
          cell.slider.maximumTrackTintColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            cell.replyView.backgroundColor = UIColor.lightText.withAlphaComponent(0.15)
            cell.replyText.textColor = UIColor.lightGray
          
            cell.bubbleRightAnchor?.isActive = true
            cell.bubbleLeftAnchor?.isActive = false
            
        } else {
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            cell.timerLabel.textColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
            cell.msgTime.textColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
          cell.slider.tintColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
          cell.slider.maximumTrackTintColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
          cell.readReceipt.isHidden = true
          cell.readReceiptWidth!.constant = 0
            cell.replyView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.15)
            cell.replyText.textColor = UIColor.darkGray.withAlphaComponent(0.75)
            
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
        }
        
      if let seconds = message.timeStamp?.doubleValue {
          let date = Date(timeIntervalSince1970: seconds)
          
          let formatter = DateFormatter()
          formatter.dateFormat = "hh:mm a"
          cell.msgTime.text = formatter.string(from: date)
          
          if let duration = message.audioDuration {
              var currentMins = Int(duration) / 60
              var currentSec = Int(duration) % 60
              var timer = String(format: "%02i:%02i", currentMins,currentSec)

              cell.timerLabel.text = timer
          }
      }
      
      cell.slider.setThumbImage(makeCircleWith(size: CGSize(width: 15, height: 15), backgroundColor: UIColor.brown), for: .normal)
      cell.slider.setThumbImage(makeCircleWith(size: CGSize(width: 15, height: 15), backgroundColor: UIColor.brown), for: .highlighted)
        
        if let replyTimeStamp = message.value(forKey: "replyTimeStamp") as? NSNumber {
            for i in 0...messages.count-1 {
                
                if replyTimeStamp.isEqual(to: messages[i].timeStamp!) {
                    
                    if messages[i].fromUUID == self.currentUserUID {
                        cell.replyName.text = "You"
                    }else if messages[i].fromUUID == self.contact!.id {
                        cell.replyName.text = self.contact?.name
                    }
                    
                    cell.replyText.text = messages[i].text
                    
                    if let replyImageURL = messages[i].imageURL {
                        cell.replyImageWidthAnchor?.isActive = true
                        cell.replyImageView.loadImageUsingCacheWithUrlString(replyImageURL)
                    }
                }
            }
        }
    }
    
    fileprivate func setupFileCell(_ cell: chatBubbleFileCell, message: Message) {
        if message.fromID == currentUserEmail ||  message.fromID == currentUserPhone{
            //outgoing blue
            cell.bubbleView.backgroundColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
            cell.nameLabel.textColor = UIColor.white
            cell.msgTime.textColor = UIColor.white
            cell.readReceipt.isHidden = false
            cell.readReceiptWidth!.constant = 19
            
            cell.bubbleRightAnchor?.isActive = true
            cell.bubbleLeftAnchor?.isActive = false
            
        } else {
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            cell.nameLabel.textColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
            cell.msgTime.textColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
            cell.readReceipt.isHidden = true
            cell.readReceiptWidth!.constant = 0
            
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
        }
        
        cell.nameLabel.text = message.fileName
        cell.extLabel.text = message.fileExt
        if let seconds = message.timeStamp?.doubleValue {
            let date = Date(timeIntervalSince1970: seconds)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            cell.msgTime.text = formatter.string(from: date)
        }
    }
    
    fileprivate func setupReplyFileCell(_ cell: ReplyBubbleFileCell, message: Message) {
        if message.fromID == currentUserEmail ||  message.fromID == currentUserPhone{
            //outgoing blue
            cell.bubbleView.backgroundColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
            cell.nameLabel.textColor = UIColor.white
            cell.msgTime.textColor = UIColor.white
            cell.readReceipt.isHidden = false
            cell.readReceiptWidth!.constant = 19
            cell.replyView.backgroundColor = UIColor.lightText.withAlphaComponent(0.15)
            cell.replyText.textColor = UIColor.lightGray
            
            cell.bubbleRightAnchor?.isActive = true
            cell.bubbleLeftAnchor?.isActive = false
            
        } else {
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            cell.nameLabel.textColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
            cell.msgTime.textColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
            cell.readReceipt.isHidden = true
            cell.readReceiptWidth!.constant = 0
            cell.replyView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.15)
            cell.replyText.textColor = UIColor.darkGray.withAlphaComponent(0.75)
            
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
        }
        
        cell.nameLabel.text = message.fileName
        cell.extLabel.text = message.fileExt
        if let seconds = message.timeStamp?.doubleValue {
            let date = Date(timeIntervalSince1970: seconds)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            cell.msgTime.text = formatter.string(from: date)
        }
        
        if let replyStamp = message.value(forKey: "replyTimeStamp") as? NSNumber {
            if let replyMessage = coreDataManager.shared.fetchMessage(timeStamp: replyStamp) {
                if replyMessage.fromUUID == self.currentUserUID {
                    cell.replyName.text = "You"
                }else if replyMessage.fromUUID == self.contact!.id {
                    cell.replyName.text = self.contact?.name
                }
                
                cell.replyText.text = replyMessage.text
                
                if let replyImageURL = replyMessage.imageURL {
                    cell.replyImageWidthAnchor?.isActive = true
                    cell.replyImageView.loadImageUsingCacheWithUrlString(replyImageURL)
                }
            }
        }
    }
    
    fileprivate func setupCell(_ cell: chatBubbleCell, message: Message) {
        
        
        if message.fromID == currentUserEmail ||  message.fromID == currentUserPhone{
            //outgoing blue
            cell.bubbleView.backgroundColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
            cell.textView.textColor = UIColor.white
            cell.msgTime.textColor = UIColor.white
            cell.readReceipt.isHidden = false
            cell.readReceiptWidth!.constant = 19
            
            cell.bubbleRightAnchor?.isActive = true
            cell.bubbleLeftAnchor?.isActive = false
            
        } else {
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            cell.textView.textColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
            cell.msgTime.textColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
            cell.readReceipt.isHidden = true
            cell.readReceiptWidth!.constant = 0
            
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
        }
        
        if let messageImageUrl = message.imageURL {
            cell.imageView.loadImageUsingCacheWithUrlString(messageImageUrl)
            cell.imageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.imageView.isHidden = true
        }
        
        if let text = message.text {
            //a text message
            if estimateFrameForText(text: text).width < 70 {
                 cell.bubbleWidthAnchor?.constant = 100
            }else{
                cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            }

            cell.textView.isHidden = false
            //cell.isUserInteractionEnabled = false
        }
        if message.imageURL != nil {
            //fall in here if its an image message
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
           // cell.isUserInteractionEnabled = true
        }

        cell.textView.text = message.text
        
        
        if let seconds = message.timeStamp?.doubleValue {
            let date = Date(timeIntervalSince1970: seconds)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            cell.msgTime.text = formatter.string(from: date)
        }
        
        cell.playButton.isHidden = message.videoURL == nil
        cell.imageView.isUserInteractionEnabled = message.videoURL == nil
    }
    
    fileprivate func setupReplyCell(_ cell: ReplyBubbleCell, message: Message) {
        
        if message.fromID == currentUserEmail ||  message.fromID == currentUserPhone{
            //outgoing blue
            cell.bubbleView.backgroundColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
            cell.textView.textColor = UIColor.white
            cell.msgTime.textColor = UIColor.white
            cell.readReceipt.isHidden = false
            cell.readReceiptWidth!.constant = 19
            cell.replyView.backgroundColor = UIColor.lightText.withAlphaComponent(0.16)
            cell.replyText.textColor = UIColor.lightGray
            
            cell.bubbleRightAnchor?.isActive = true
            cell.bubbleLeftAnchor?.isActive = false
            
        } else {
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            cell.textView.textColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
            cell.msgTime.textColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1)
            cell.readReceipt.isHidden = true
            cell.readReceiptWidth!.constant = 0
            cell.replyView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.15)
            cell.replyText.textColor = UIColor.darkGray.withAlphaComponent(0.75)
            
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
        }
        
        if let replyStamp = message.value(forKey: "replyTimeStamp") as? NSNumber {
            if let replyMessage = coreDataManager.shared.fetchMessage(timeStamp: replyStamp){
                var width = estimateFrameForText(text: message.text!).width
                
                if replyTimeStamp.isEqual(to: replyMessage.timeStamp!) {
                    
                    
                    if replyMessage.fromUUID == self.currentUserUID {
                        cell.replyName.text = "You"
                    }else if replyMessage.fromUUID == self.contact!.id {
                        if let name = self.contact?.name {
                            cell.replyName.text = self.contact?.name
                            if width < estimateFrameForText(text: self.contact!.name!).width {
                                width = estimateFrameForText(text: self.contact!.name!).width
                            }
                        }
                        else{
                            cell.replyName.text = "Unknown"
                        }
                    }
                    
                    if width < estimateFrameForText(text: replyMessage.text!).width {
                        if estimateFrameForText(text: replyMessage.text!).width < 100 {
                            cell.bubbleWidthAnchor?.constant = 140
                        }else{
                            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: replyMessage.text!).width + 32
                        }
                    }else{
                        if width < 100 {
                            cell.bubbleWidthAnchor?.constant = 140
                        }else{
                            cell.bubbleWidthAnchor?.constant = width + 32
                        }
                    }
                    
                    cell.replyText.text = replyMessage.text
                    
                    if let replyImageURL = replyMessage.imageURL {
                        cell.replyImageWidthAnchor?.isActive = true
                        cell.replyImageView.loadImageUsingCacheWithUrlString(replyImageURL)
                    }
                }
            }
        }
        
        if let messageImageUrl = message.imageURL {
            cell.imageView.loadImageUsingCacheWithUrlString(messageImageUrl)
            cell.imageView.isHidden = false
            cell.imageView.layer.cornerRadius = 5
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
            cell.replyImageWidthAnchor!.isActive = true
        } else {
            cell.imageView.isHidden = true
            cell.textView.isHidden = false
        }
        
        cell.textView.text = message.text
        
        
        if let seconds = message.timeStamp?.doubleValue {
            let date = Date(timeIntervalSince1970: seconds)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            cell.msgTime.text = formatter.string(from: date)
        }
        
        cell.playButton.isHidden = message.videoURL == nil
        cell.imageView.isUserInteractionEnabled = message.videoURL == nil
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.replyTimeStamp = 0
        self.replyHint.isHidden = true
        self.replyName.isHidden = true
        self.replyText.isHidden = true
        self.replyImage.isHidden = true
        self.replyCancelButton.isHidden = true
        self.replyViewHeight.constant = 49
    }
    
    func scrollToMessage(message: Message){
        if let replyTimeStamp = message.value(forKey: "replyTimeStamp") as? NSNumber {
            for i in 0...messages.count-1 {
                
                if replyTimeStamp.isEqual(to: messages[i].timeStamp!) {
                    let indexPath = IndexPath(row: i, section: 0)
                    collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
            
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                        
                        self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
                        
                    }, completion: nil)
                    
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                        
                        self.collectionView.deselectItem(at: indexPath, animated: true)
                        
                    }, completion: nil)
                }
            }
        }
    }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            var height: CGFloat = 80
            let message = messages[indexPath.item]
            if let text = message.text {
                if message.replyTimeStamp != 0 && estimateFrameForText(text: text).height.isLess(than: 20) {
                    height = estimateFrameForText(text: text).height + 30
                }else {
                    height = estimateFrameForText(text: text).height + 40
                }
                     
            }
            
            if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
                
                // h1 / w1 = h2 / w2
                // solve for h1
                // h1 = h2 / w2 * w1

                height = CGFloat(imageHeight / imageWidth * 200)
                
            }
            
            if message.audioURL != nil && message.replyTimeStamp != 0 {
                height = 55
            }
            
            if message.fileURL != nil {
                if message.replyTimeStamp != 0 {
                    height = 65
                }else{
                   height = 70
                }
            }
            
            if message.replyTimeStamp != 0 {
                height += 60
            }
            
            let width = UIScreen.main.bounds.width
            return CGSize(width: width, height: height)
        }
    
    private func estimateFrameForText(text: String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }

    @IBOutlet weak var msgInputField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.register(chatBubbleCell.self, forCellWithReuseIdentifier: "chatBubble")
        collectionView.register(ReplyBubbleCell.self, forCellWithReuseIdentifier: "ReplyBubble")
        collectionView.register(chatBubbleFileCell.self, forCellWithReuseIdentifier: "fileChatBubble")
        collectionView.register(ChatBubbleAudioCell.self, forCellWithReuseIdentifier: "audioChatBubble")
        collectionView.register(ReplyBubbleFileCell.self, forCellWithReuseIdentifier: "fileReplyBubble")
        collectionView.register(ReplyBubbleAudioCell.self, forCellWithReuseIdentifier: "audioReplyBubble")
        audioMessageButton.setImage(UIImage(named: "Voice Message icon"), for: .normal)
        
        imagePickerController.delegate = self
        docPicker.delegate = self
        msgInputField.setPadding()
        msgInputField.attributedPlaceholder = NSAttributedString(string: "Write message here...", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 200/255, green: 184/255, blue: 207/255, alpha: 1)])
        msgInputField.layer.cornerRadius = 15.5
        msgInputField.layer.borderWidth = 1
        msgInputField.layer.borderColor = UIColor(red: 116/255, green: 41/255, blue: 148/255, alpha: 1).cgColor
        setupKeyboardObservers()
        collectionView?.alwaysBounceVertical = true
        recordTimer.isHidden = true
        soundRecorder = nil
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .spokenAudio, options: .defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("error.")
        }
        
        indicator.isHidden = true
        indicator.style = UIActivityIndicatorView.Style.whiteLarge
        indicator.color = UIColor.darkGray

        replyImage.layer.cornerRadius = 11
        replyImage.clipsToBounds = true
        replyHint.isHidden = true
        replyName.isHidden = true
        replyText.isHidden = true
        replyImage.isHidden = true
        replyCancelButton.isHidden = true
        replyName.isUserInteractionEnabled  = false
        replyText.isUserInteractionEnabled  = false
        
        self.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard)))
        // Do any additional setup after loading the view.
    }
    
    @objc func hideKeyBoard(){
        self.msgInputField.resignFirstResponder()
    }
    
      func setupKeyboardObservers() {
            NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
            
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    
        @objc func handleKeyboardDidShow() {
            
            
        }
    
    func scrollToLastMessage()
    {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        var temp = [Message]()
        temp = coreDataManager.shared.fetchSortedMessages()
        self.messages = temp.filter({( message : Message) -> Bool in
            let con = message.toUUID==contact?.id || message.fromUUID == contact?.id
            return con && message.groupID == nil
        })
        self.collectionView.reloadData()
        
        observeUserMessages()
        deleteSeenMessagesFromServer()
        setupKeyboardObservers()
    }
    
    
    override func viewWillLayoutSubviews() {
        scrollToLastMessage()
    }
        
    func viewFile(message: Message){
        if let fileURL = message.fileURL {
            indicator.startAnimating()
            indicator.isHidden = false
            let url = URL(string: fileURL)
           
            let docC = UIDocumentInteractionController(url: url!)
            docC.delegate = self
            docC.presentPreview(animated: true)
            self.indicator.isHidden = true
            self.indicator.stopAnimating()
            
            return
        }
    }
    
    @objc func handleKeyboardWillShow(_ notification: Notification) {
            let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
            keyBoardheight = keyboardFrame!.height
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                   self.replyViewBottom.constant = +keyboardFrame!.height-49
                   self.audioMsgBottom?.constant = +keyboardFrame!.height-43
                   self.inputFieldBottom?.constant = +keyboardFrame!.height-45
                   self.attachBottom?.constant = +keyboardFrame!.height-44
               }, completion: nil)
    
            UIView.animate(withDuration: keyboardDuration!, animations: {
                self.view.layoutIfNeeded()
            })
        }
    @IBOutlet weak var audioMsgBottom: NSLayoutConstraint!
    @IBOutlet weak var attachBottom: NSLayoutConstraint!
    @IBOutlet weak var inputFieldBottom: NSLayoutConstraint!
    
    @objc func handleKeyboardWillHide(_ notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.replyViewBottom.constant = 0
            self.replyViewHeight.constant = 49
            self.audioMsgBottom?.constant = 7
            self.inputFieldBottom?.constant = 5
            self.attachBottom?.constant = 6
            self.replyHint.isHidden = true
            self.replyName.isHidden = true
            self.replyText.isHidden = true
            self.replyImage.isHidden = true
            self.replyCancelButton.isHidden = true
        }, completion: nil)
        
            UIView.animate(withDuration: keyboardDuration!, animations: {
                self.view.layoutIfNeeded()
            })
        }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.replyHint.isHidden = true
            self.replyName.isHidden = true
            self.replyText.isHidden = true
            self.replyImage.isHidden = true
            self.replyCancelButton.isHidden = true
            self.replyViewHeight.constant = 49
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        if msgInputField.text != "" {
            var toID: String?
            if self.contact?.phone != nil {
                toID = self.contact?.phone
                
            }else{
                toID = self.contact?.email as String?
            }
            let email = Auth.auth().currentUser?.email
            let phone = Auth.auth().currentUser?.phoneNumber
            var fromID:  String?
            if email != nil {
                fromID = email
            }else {
                fromID = phone
            }
            
            let timeStamp: NSNumber = NSNumber(value: NSDate().timeIntervalSince1970)
            
            var values = ["isSeen": "false","replyTimeStamp": replyTimeStamp,"text": msgInputField.text, "toID": toID, "fromID": fromID, "timeStamp": timeStamp, "fromUUID": self.currentUserUID, "toUUID": self.contact?.id] as [String : Any]
            
            coreDataManager.shared.createMessage(dictionary: values)
            var temp = [Message]()
            temp = coreDataManager.shared.fetchMessages()
            self.messages = temp.filter({( message : Message) -> Bool in
                return (message.toUUID==contact?.id || message.fromUUID == contact?.id) && message.groupID == nil
            })

            self.collectionView.reloadData()
            scrollToLastMessage()
            let data: Data = (msgInputField.text?.data(using: .utf8))!
            let encryptedData = self.encrypt(data: data, key: key)
            let msg: String = encryptedData.base64EncodedString()
            values["text"] = msg
            uploadMsgWithValues(values: values)
            msgInputField.text = nil
        }
        
        return true
    }
    
     func uploadMsgWithValues(values: [String: Any]){
        
           let ref =  Database.database().reference().child("messages")
                  let childRef = ref.childByAutoId()
           childRef.updateChildValues(values)
           
           let senderRef = Database.database().reference().child("userMessages").child(self.currentUserUID!).child((self.contact?.id)!)
           senderRef.updateChildValues([childRef.key as! String: ""])
           
           let rID = self.contact?.id
           let recipientRef = Database.database().reference().child("userMessages").child((self.contact?.id)!).child(self.currentUserUID!)
           recipientRef.updateChildValues([childRef.key as! String: ""])
           self.replyTimeStamp = 0
    }
    
    @objc func updateTimer(){
        DispatchQueue.main.async {
            let seconds = self.soundRecorder.currentTime
               
               let date = Date(timeIntervalSince1970: seconds)
                   
               let formatter = DateFormatter()
               
               formatter.dateFormat = "mm:ss"
            self.recordTimer.text = formatter.string(from: date)
           }
        
    }
    
    var timer = Timer()
    @IBAction func recordAudio(_ sender: Any) {
        if soundRecorder == nil {
            setupRecorder()
        }
        
        
        if audioMessageButton.image(for: .normal) == UIImage(named: "Voice Message icon") {
            audioMessageButton.setImage(UIImage(named: "Send"), for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            
            timer.fire()
            msgInputField.isEnabled = false
            recordTimer.isHidden = false
            soundRecorder.record()
          
        } else {
            audioMessageButton.setImage(UIImage(named: "Voice Message icon"), for: .normal)
            soundRecorder.stop()
        }
    }
    
    func sendAudioMsgWithUrl(localURL: URL){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.replyHint.isHidden = true
            self.replyName.isHidden = true
            self.replyText.isHidden = true
            self.replyImage.isHidden = true
            self.replyCancelButton.isHidden = true
            self.replyViewHeight.constant = 49
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        var toID: String?
        if self.contact?.phone != nil {
            toID = self.contact?.phone as String?
        }else{
            toID = self.contact?.email as String?
        }
        
        var fromID:  String?
        if self.currentUserEmail != nil {
            fromID = self.currentUserEmail
        }else {
            fromID = self.currentUserPhone
        }
        let timeStamp: NSNumber = NSNumber(value: NSDate().timeIntervalSince1970)
        let fileName = localURL.lastPathComponent
        //path.removeLast()
        
        let asset = AVURLAsset(url: localURL)
        let duration = asset.duration.seconds;
        var values = ["isSeen": "false","replyTimeStamp": replyTimeStamp,"filename": fileName,"text": "Audio","audioURL": localURL.absoluteString, "toID": toID, "fromID": fromID, "timeStamp": timeStamp,"audioDuration": duration, "fromUUID": self.currentUserUID, "toUUID": self.contact?.id] as [String : Any]
        
        coreDataManager.shared.createMessage(dictionary: values)
        var temp = [Message]()
        temp = coreDataManager.shared.fetchMessages()
        self.messages = temp.filter({( message : Message) -> Bool in
        return (message.toUUID==contact?.id || message.fromUUID == contact?.id) && message.groupID == nil
        })

        self.collectionView.reloadData()
        scrollToLastMessage()
        
        let ref = Storage.storage().reference().child("messageAudios").child(localURL.lastPathComponent)
        print("uploading audio")
        do{
            let audio = try Data(contentsOf: localURL)
            let encryptedAudio = self.encrypt(data: audio, key: key)
            ref.putData(encryptedAudio, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        print("Failed to upload image:", error!)
                        return
                    }
                    
                    ref.downloadURL(completion: { (downloadURL, err) in
                        if let err = err {
                            print(err)
                            return
                        }
                       
                        values["audioURL"] = downloadURL?.absoluteString
                        self.uploadMsgWithValues(values: values)
                    })
            })
        }
        catch{
            print("failed to upload audio")
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            
        NotificationCenter.default.removeObserver(self)
         let seenRef = Database.database().reference().child("seenMessages").child(currentUserUID!).child((contact?.id)!)
        seenRef.removeAllObservers()
        let ref = Database.database().reference().child("userMessages").child(currentUserUID!).child((contact?.id)!)
        ref.removeAllObservers()
        let ref2 = Database.database().reference().child("messages")
        ref2.removeAllObservers()
    }
    
    func deleteSeenMessagesFromServer(){
        
        let seenRef = Database.database().reference().child("seenMessages").child(currentUserUID!).child((contact?.id)!)
        seenRef.observe(.childAdded) { (snapshot) in
           
            let msgID = snapshot.key
            let msgRef = Database.database().reference().child("messages").child(msgID)
            msgRef.observeSingleEvent(of: .value) { (snap) in
                if let dictionary = snap.value as? [String: AnyObject] {
                    if (self.currentUserUID!.isEqual(dictionary["fromUUID"] as! String )) {
                      
                        var i = (self.messages.count-1)
                        var found = false
                        while !found && i>=0 {
                            if (self.messages[i].timeStamp?.isEqual(to: dictionary["timeStamp"] as! NSNumber ))! && self.messages[i].fromUUID == self.currentUserUID {
                                
                                if self.messages[i].isSeen == "false" {
                                    let time = dictionary["timeStamp"] as! NSNumber
                                    coreDataManager.shared.updateMessage(timeStamp: time,key: "isSeen",value: "true")
                                    self.messages[i].isSeen = "true"
                                    self.collectionView.reloadData()
                                }

                                found = true
                                msgRef.removeValue { (error, dbref) in

                                let senderRef = Database.database().reference().child("userMessages").child(self.currentUserUID!).child((self.contact?.id)!)
                                senderRef.child(snapshot.key).removeValue()

                                let recipientRef = Database.database().reference().child("userMessages").child((self.contact?.id)!).child(self.currentUserUID!)
                                recipientRef.child(snapshot.key).removeValue()
                                snapshot.ref.removeValue()
                                           }
                            }
                            i -= 1
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
    
    func observeUserMessages(){
        guard let uid = Auth.auth().currentUser?.uid , let cID = contact?.id else {
            return
        }
        let ref = Database.database().reference().child("userMessages").child(uid).child(cID)
      
        ref.observe(.childAdded) { (snapshot) in
            let msgID = snapshot.key
            let msgRef = Database.database().reference().child("messages").child(msgID)
            msgRef.observeSingleEvent(of: .value) { (snap) in
                 if let dictionary = snap.value as? [String: AnyObject] {
                    let stamp = dictionary["timeStamp"] as! NSNumber
                    var saved = Bool()
                    if coreDataManager.shared.fetchMessage(timeStamp: stamp) != nil {
                        saved = true
                    }
                    if !saved {
                        var  temp = dictionary
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
                            
                        var temp2 = [Message]()
                        temp2 = coreDataManager.shared.fetchSortedMessages()
                        self.messages = temp2.filter({( message : Message) -> Bool in
                            let con = message.toUUID==self.contact?.id || message.fromUUID == self.contact?.id
                            return con && message.groupID == nil
                        })
                        
                        let message = self.messages.last
                        print("saving from within the indi chatlog",message)
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
                        
                        temp["isSeen"] = "true" as AnyObject
                        msgRef.updateChildValues(temp)
                        let seenRef = Database.database().reference().child("seenMessages").child(cID).child(uid)
                        seenRef.updateChildValues([msgRef.key!: ""])
                        }
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                            self.scrollToLastMessage()
                        }
                }
            }
        }
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
   // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue}

}

@available(iOS 10.0, *)
extension ChatLogViewController: AVAudioRecorderDelegate{
    
    func setupRecorder() {
        
        let audioFilePath = getDocumentsDirectory()?.appendingPathComponent(UUID().uuidString).appendingPathExtension("m4a")
        
        let recordSetting = [ AVFormatIDKey : kAudioFormatAppleLossless,
                              AVEncoderAudioQualityKey : AVAudioQuality.min.rawValue,
        AVEncoderBitRateKey : 128000,
        AVNumberOfChannelsKey : 1,
        AVSampleRateKey : 12000] as [String : Any]
        
        do {
            soundRecorder = try AVAudioRecorder(url: audioFilePath!, settings: recordSetting )
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
        } catch {
            print(error)
        }
    }

    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        timer.invalidate()
        msgInputField.isEnabled = true
        recordTimer.isHidden = true
        sendAudioMsgWithUrl(localURL: recorder.url)
        self.soundRecorder = nil
    }
    
    func makeCircleWith(size: CGSize, backgroundColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(backgroundColor.cgColor)
        context?.setStrokeColor(UIColor.clear.cgColor)
        let bounds = CGRect(origin: .zero, size: size)
        context?.addEllipse(in: bounds)
        context?.drawPath(using: .fill)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func encrypt(data: Data, key: String) -> Data{
        let encryptedData = try RNCryptor.encrypt(data: data, withPassword: key)
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


