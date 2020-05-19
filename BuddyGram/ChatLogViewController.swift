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

let imageCache = NSCache<NSString, UIImage>()

class ChatLogViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIDocumentPickerDelegate,UIDocumentInteractionControllerDelegate{
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var recordTimer: UILabel!
    
    @IBOutlet weak var audioMessageButton: UIButton!
    @IBOutlet weak var attachButton: UIButton!
    var selectedIndexPath: IndexPath!
    var soundRecorder : AVAudioRecorder!
   // var audioFilePath: URL?
    
    var messages = [Message]()
    let currentUserEmail = Auth.auth().currentUser?.email
    let currentUserPhone = Auth.auth().currentUser?.phoneNumber
    let currentUserUID = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var collectionView: UICollectionView!
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.showed {
            self.msgInputField.resignFirstResponder()
            return
        }
        
        self.selectedIndexPath = indexPath
        
        let message = messages[indexPath.item]
        if let fileURL = message.fileURL {
            indicator.startAnimating()
            indicator.isHidden = false
            let url = URL(string: fileURL)
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                       
                DispatchQueue.main.async(execute: {
                   self.savetoDocumentsFolder(data: data!, message: message)
            
                    let file = self.getDocumentsDirectory()?.appendingPathComponent(message.fileName!).appendingPathExtension(message.fileExt!)
                   let docC = UIDocumentInteractionController(url: file!)
                   docC.delegate = self
                    self.indicator.isHidden = true
                    self.indicator.stopAnimating()
                   docC.presentPreview(animated: true)
                    })
                }).resume()
            return
        }
        if message.videoURL == nil {
            if message.imageURL != nil  {
                let vc = storyboard?.instantiateViewController(withIdentifier: "imageDetail") as! ZoomedViewController
                if let cachedImage = imageCache.object(forKey: message.imageURL as! NSString) as? UIImage {
                        vc.image = cachedImage
                    }
                          
                    self.navigationController?.pushViewController(vc, animated: true)
            }
        }else {
            let url = URL(string: message.videoURL!)
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
                //  videoView.addSubview(controller.view)
            
            self.present(controller, animated: true, completion: nil)
            player.play()
            player.actionAtItemEnd = .none
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
        self.msgInputField.text = "UPLOADING MESSAGE..."
        let filename = urls.first!.lastPathComponent
        let ext = urls.first!.pathExtension
        let url = urls.first
        
        var toID: String?
        if self.contact?.phone != "" {
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
        
        let ref = Storage.storage().reference().child("files").child(filename)
        ref.putFile(from: url!, metadata: nil) { (metadata, err) in
            ref.downloadURL { (downloadURL, error) in

                let values = ["isSeen": "false","ext": ext,"fileURL": downloadURL?.absoluteString,"filename": filename,"text": "File","toID": toID, "fromID": fromID, "timeStamp": timeStamp] as [String : Any]
                self.uploadMsgWithValues(values: values)
            }
        }
    }
    
    let imagePickerController = UIImagePickerController()
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.msgInputField.text = "UPLOADING MESSAGE..."
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
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child("messageImages").child(imageName)
        
        if let uploadData = image.jpegData(compressionQuality: 0.2) {
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
                    
                    self.sendImageMsgWithUrl(url: downloadURL?.absoluteString ?? "", image: image)
                })
                
            })
        }
    }
    
    func sendAudioMsgWithUrl(localURL: URL){
        var toID: String?
        if self.contact?.phone != "" {
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
        
        
        let ref = Storage.storage().reference().child("messageAudios").child(localURL.lastPathComponent)
        print("uploading audio")
        ref.putFile(from: localURL, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("Failed to upload image:", error!)
                    return
                }
                
                ref.downloadURL(completion: { (downloadURL, err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    
                    var path = localURL.absoluteString
                    //path.removeLast()
                    
                    let asset = AVURLAsset(url: localURL)
                    let duration = asset.duration.seconds;
                    
                    let values = ["isSeen": "false","filename": path,"text": "Audio","audioURL": downloadURL?.absoluteString, "toID": toID, "fromID": fromID, "timeStamp": timeStamp,"audioDuration": duration] as [String : Any]
                    self.uploadMsgWithValues(values: values)
                })
        })
    }
    
    func sendImageMsgWithUrl(url: String, image: UIImage){
        var toID: String?
        if self.contact?.phone != "" {
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
        let values = ["isSeen": "false","text": "Photo","imageURL": url, "toID": toID, "fromID": fromID, "timeStamp": timeStamp,"imageWidth": image.size.width,"imageHeight": image.size.height] as [String : Any]
        self.uploadMsgWithValues(values: values)
    }
    
    func uploadVideoToFirebase(videoURL: URL){
        let filename = NSUUID().uuidString + ".mov"
                   
                   let ref = Storage.storage().reference().child("messageVideos").child(filename)
                      let upload =  ref.putFile(from: videoURL, metadata: nil) { (metadata, err) in
                       ref.downloadURL { (downloadURL, err) in
                        let image = self.thumbnailForVideo(videoURL: videoURL)
                        self.putVideoMsgWithUrl(url: downloadURL!.absoluteString, image: image!)
                       }
                   }
                   upload.observe(.progress) { (Snapshot) in
                       print(Snapshot.progress?.completedUnitCount)
                   }
    }
    
    func putVideoMsgWithUrl(url: String,image: UIImage){
        
        var toID: String?
        if self.contact?.phone != "" {
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
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("messageImages").child(imageName)
        
        if let uploadData = image.jpegData(compressionQuality: 0.2) {
            ref.putData(uploadData, metadata: nil) { (metaData, error) in
                ref.downloadURL { (imageURL, err) in
                    let values = ["isSeen": "false","text": "Video","videoURL": url, "toID": toID, "fromID": fromID, "timeStamp": timeStamp,"imageHeight": image.size.height,"imageWidth": image.size.width,"imageURL": imageURL?.absoluteString] as [String : Any]
                    self.uploadMsgWithValues(values: values)
                }
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
                if #available(iOS 11.0, *) {
                    self.docPicker.allowsMultipleSelection  = false
                } else {
                    // Fallback on earlier versions
                }
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
            
            if let audioURL = message.audioURL {
                let audioCell = collectionView.dequeueReusableCell(withReuseIdentifier: "audioChatBubble", for: indexPath) as! ChatBubbleAudioCell
                setupAudioCell(audioCell, message: message)
                audioCell.message = message
                
                if message.isSeen == "true" {
                    audioCell.readReceipt.image = UIImage(named: "seen")
                }else{
                    audioCell.readReceipt.image = UIImage(named: "delivered")
                }
                
                return audioCell
            }
            
            if let fileURL = message.fileURL {
                let fileCell = collectionView.dequeueReusableCell(withReuseIdentifier: "fileChatBubble", for: indexPath) as! chatBubbleFileCell
            
                setupFileCell(fileCell, message: message)
                
                if message.isSeen == "true" {
                    fileCell.readReceipt.image = UIImage(named: "seen")
                }else{
                    fileCell.readReceipt.image = UIImage(named: "delivered")
                }
                
                fileCell.isUserInteractionEnabled = true
                return fileCell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatBubble", for: indexPath) as! chatBubbleCell
            
            
            cell.textView.text = message.text
            
            setupCell(cell, message: message)
            
            if let text = message.text {
                //a text message
                if estimateFrameForText(text: text).width < 100 {
                     cell.bubbleWidthAnchor?.constant = 140
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
            
            cell.message = message
            
            
            if let seconds = messages[indexPath.row].timeStamp?.doubleValue {
                let date = Date(timeIntervalSince1970: seconds)
                
                let formatter = DateFormatter()
                formatter.dateFormat = "hh:mm a"
                cell.msgTime.text = formatter.string(from: date)
            }
            
            if message.isSeen == "true" {
                cell.readReceipt.image = UIImage(named: "seen")
            }else{
                cell.readReceipt.image = UIImage(named: "delivered")
            }
            
            cell.playButton.isHidden = message.videoURL == nil
            
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.collectionView.collectionViewLayout.invalidateLayout()
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
    }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            var height: CGFloat = 80
            let message = messages[indexPath.item]
            if let text = message.text {
                height = estimateFrameForText(text: text).height + 40
            }
                if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {

                // h1 / w1 = h2 / w2
                // solve for h1
                // h1 = h2 / w2 * w1

                height = CGFloat(imageHeight / imageWidth * 200)

            }
            
            if let file = message.fileURL {
                height = 70
            }
            
            let width = UIScreen.main.bounds.width
            return CGSize(width: width, height: height)
        }
    
    private func estimateFrameForText(text: String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    var contact: Contact?

    @IBOutlet weak var msgInputField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        observeUserMessages()

        
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.register(chatBubbleCell.self, forCellWithReuseIdentifier: "chatBubble")
        collectionView.register(chatBubbleFileCell.self, forCellWithReuseIdentifier: "fileChatBubble")
        collectionView.register(ChatBubbleAudioCell.self, forCellWithReuseIdentifier: "audioChatBubble")
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
            if #available(iOS 10.0, *) {
                try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .spokenAudio, options: .defaultToSpeaker)
                try audioSession.setCategory(AVAudioSession.Category.playback,options: .mixWithOthers )
            } else {
                // Fallback on earlier versions
            }
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("error.")
        }
        indicator.isHidden = true
        indicator.style = UIActivityIndicatorView.Style.whiteLarge
        indicator.color = UIColor.darkGray
        // Do any additional setup after loading the view.
    }
    
   
    
      func setupKeyboardObservers() {
            NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
            
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        var showed = false
        @objc func handleKeyboardDidShow() {
            if messages.count > 0 {
                let indexPath = IndexPath(item: messages.count - 1, section: 0)
                collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
            }
            self.showed = true
        }
    
    override func viewWillAppear(_ animated: Bool) {
        setupKeyboardObservers()
    }
        
    override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            
            NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func handleKeyboardWillShow(_ notification: Notification) {
            let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
            
            audioMsgBottom?.constant = +keyboardFrame!.height-43
            inputFieldBottom?.constant = +keyboardFrame!.height-45
            attachBottom?.constant = +keyboardFrame!.height-44
            
    
            UIView.animate(withDuration: keyboardDuration!, animations: {
                self.view.layoutIfNeeded()
            })
        }
    @IBOutlet weak var audioMsgBottom: NSLayoutConstraint!
    @IBOutlet weak var attachBottom: NSLayoutConstraint!
    @IBOutlet weak var inputFieldBottom: NSLayoutConstraint!
    
    @objc func handleKeyboardWillHide(_ notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
            
            audioMsgBottom?.constant = 7
            inputFieldBottom?.constant = 5
            attachBottom?.constant = 6
        
            UIView.animate(withDuration: keyboardDuration!, animations: {
                self.view.layoutIfNeeded()
            })
        self.showed = false
        }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //textField.resignFirstResponder()
        var toID: String?
        if self.contact?.phone != "" {
            toID = self.contact?.phone as String?
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
        let values = ["isSeen": "false","text": msgInputField.text, "toID": toID, "fromID": fromID, "timeStamp": timeStamp] as [String : Any]
        uploadMsgWithValues(values: values)
        self.msgInputField.text = "UPLOADING MESSAGE..."
       
        return true
    }
    
    func uploadMsgWithValues(values: [String: Any]){
        let ref =  Database.database().reference().child("messages")
               let childRef = ref.childByAutoId()
        childRef.updateChildValues(values)
        let uid = Auth.auth().currentUser?.uid
        let senderRef = Database.database().reference().child("userMessages").child(uid!)
        senderRef.updateChildValues([childRef.key as! String: ""])
        
        let rID = self.contact?.id
        let recipientRef = Database.database().reference().child("userMessages").child(rID!)
        recipientRef.updateChildValues([childRef.key as! String: ""])
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
                             var  temp = dictionary
                    let message = Message(dictionary: dictionary)
                    if (message.toID == self.currentUserEmail || message.toID == self.currentUserPhone) && message.isSeen == "false"{
                        temp["isSeen"] = "true" as AnyObject
                        msgRef.updateChildValues(temp)
                    }
                   
                    if(message.getChatPartnerID().isEqual(self.contact?.email) || message.getChatPartnerID().isEqual(self.contact?.phone)){
                        
                        self.messages.append(message)
                        
                        DispatchQueue.main.async {
                            if self.msgInputField.text == "UPLOADING MESSAGE..." {
                                self.msgInputField.text = nil
                            }
                             self.collectionView.reloadData()
                            if self.messages.count > 0 {
                                let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                                self.collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
                            }
                        }
    
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


extension UITextField{
    func setPadding(){
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        self.leftView = padding
        self.leftViewMode = .always
    }
}

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(_ urlString: String) {
        
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            //download hit an error so lets return out
            if error != nil {
                print(error ?? "")
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    
                    self.image = downloadedImage
                }
            })
            
        }).resume()
    }
    
}

extension UIImage {
    
    func imageWithSize(scaledToSize newSize: CGSize) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
}

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
        self.msgInputField.text = "UPLOADING MESSAGE..."
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
}


