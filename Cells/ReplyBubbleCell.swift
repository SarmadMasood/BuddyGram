//
//  ReplyBubbleCell.swift
//  BuddyGram
//
//  Created by Mac OSX on 5/25/20.
//  Copyright © 2020 Mac OSX. All rights reserved.
//

import UIKit

@available(iOS 10.0, *)
class ReplyBubbleCell: UICollectionViewCell {
    var message: Message!
    var chatLogVC: ChatLogViewController!
    var groupChatVC: GroupChatViewController!
    
       lazy var playButton: UIButton = {
           let b = UIButton(type: .system)
           b.setImage(UIImage(named: "PlayButton"), for: .normal)
           b.translatesAutoresizingMaskIntoConstraints = false
           b.tintColor = UIColor.darkGray
           b.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
           return b
       }()
       
       @objc func playVideo(){
            if message.groupID == nil {
                chatLogVC.playVideo(message: message)
            }else{
                groupChatVC.playVideo(message: message)
            }
       }
       
       let textView: UITextView = {
           let tv = UITextView()
           tv.isEditable = false
           tv.text = "Sample text for now"
           tv.font = UIFont.systemFont(ofSize: 16)
           tv.translatesAutoresizingMaskIntoConstraints = false
           tv.backgroundColor = UIColor.clear
           tv.textColor = UIColor.white
           tv.isScrollEnabled = false
           tv.isSelectable = false
           tv.isUserInteractionEnabled = false
           tv.textAlignment = .left
           return tv
       }()
       
       let msgTime: UILabel = {
           let label = UILabel()
           label.font = UIFont.systemFont(ofSize: 13)
           label.textColor = UIColor.white
           label.translatesAutoresizingMaskIntoConstraints = false
           label.backgroundColor = UIColor.clear
           return label
       }()
       
       lazy var bubbleView: UIView = {
           let v = UIView()
           v.backgroundColor = UIColor.purple
           v.translatesAutoresizingMaskIntoConstraints = false
           v.isUserInteractionEnabled = true
           v.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(replyAction)))
           return v
       }()
       
       @objc func replyAction(){
           if message.groupID == nil {
               chatLogVC.presentReplyAction(message: message)
           }else{
               groupChatVC.presentReplyAction(message: message)
           }
       }
       
       lazy var imageView: UIImageView = {
           let imv = UIImageView()
           imv.backgroundColor = UIColor.clear
           imv.contentMode = .scaleAspectFill
           imv.layer.cornerRadius = 10
           imv.layer.masksToBounds = true
           imv.translatesAutoresizingMaskIntoConstraints = false
           imv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showImage)))
           return imv
       }()
       
       @objc func showImage(){
           if message.groupID == nil {
               chatLogVC.showImage(message: message)
           }else{
               groupChatVC.showImage(message: message)
           }
       }
       
       let readReceipt: UIImageView = {
           let imv = UIImageView()
           imv.backgroundColor = UIColor.clear
           imv.image = UIImage(named: "ReadReceipt")
           imv.translatesAutoresizingMaskIntoConstraints = false
           return imv
       }()
    
    lazy var replyView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 0.15)
        view.layer.cornerRadius = 7
        view.clipsToBounds = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scrollToMessage)))
        return view
    }()
    
    @objc func scrollToMessage(){
        if message.groupID == nil {
            chatLogVC.scrollToMessage(message: message)
        }else{
            groupChatVC.scrollToMessage(message: message)
        }
    }
    
    let replyName: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.boldSystemFont(ofSize: 16)
        l.text = "Name"
        l.textColor = UIColor(red: 100/255, green: 52/255, blue: 28/255, alpha: 1)
        l.isUserInteractionEnabled = false
        return l
    }()
    
    let replyText: UILabel = {
        let l = UILabel()
        l.text = "Message text"
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 15)
        l.isUserInteractionEnabled = false
        l.textColor = UIColor.lightGray
        l.alpha = 1.0
        return l
    }()
    
    let replyImageView: UIImageView = {
        let imv = UIImageView()
        imv.translatesAutoresizingMaskIntoConstraints = false
        imv.isUserInteractionEnabled = false
        imv.contentMode = .scaleAspectFill
        return imv
    }()
    
    let replyHint: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 100/255, green: 51/255, blue: 28/255, alpha: 1)
        view.alpha = 1.0
        return view
    }()
    
    let groupUser: UILabel = {
        let label = UILabel()
        label.text = "~group user"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        label.isHidden = true
        return label
    }()
       
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleHeightAnchor: NSLayoutConstraint?
    var bubbleRightAnchor: NSLayoutConstraint?
    var bubbleLeftAnchor: NSLayoutConstraint?
    var readReceiptWidth: NSLayoutConstraint?
    var replyImageWidthAnchor: NSLayoutConstraint?
    var groupAnchor: NSLayoutConstraint?
    var nonGroupAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(msgTime)
        addSubview(readReceipt)
        addSubview(groupUser)
        
        bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor,constant: -8)
        bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: self.leftAnchor,constant: 8)
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleHeightAnchor = bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor)
        bubbleHeightAnchor?.isActive = true
        bubbleView.layer.cornerRadius = 10
        
        groupUser.topAnchor.constraint(equalTo: bubbleView.topAnchor,constant: 3).isActive = true
        groupUser.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 5).isActive = true
        groupUser.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        addSubview(replyView)
        replyView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 5).isActive = true
        replyView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -5).isActive = true
        replyView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        groupAnchor = replyView.topAnchor.constraint(equalTo: groupUser.bottomAnchor, constant: 5)
        groupAnchor!.isActive = false
        nonGroupAnchor = replyView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 5)
        nonGroupAnchor!.isActive = true
        
        replyView.addSubview(replyHint)
        replyHint.leftAnchor.constraint(equalTo: replyView.leftAnchor).isActive = true
        replyHint.heightAnchor.constraint(equalTo: replyView.heightAnchor).isActive = true
        replyHint.widthAnchor.constraint(equalToConstant: 8).isActive = true
        
        replyView.addSubview(replyImageView)
        replyImageView.rightAnchor.constraint(equalTo: replyView.rightAnchor).isActive = true
        replyImageView.heightAnchor.constraint(equalTo: replyView.heightAnchor).isActive = true
        replyImageWidthAnchor = replyImageView.widthAnchor.constraint(equalToConstant: 30)
        
        replyView.addSubview(replyName)
        replyName.leftAnchor.constraint(equalTo: replyHint.rightAnchor, constant: 10).isActive = true
        replyName.topAnchor.constraint(equalTo: replyView.topAnchor, constant: 4).isActive = true
        replyName.rightAnchor.constraint(equalTo: replyImageView.leftAnchor).isActive = true
        
        replyView.addSubview(replyText)
        replyText.leftAnchor.constraint(equalTo: replyHint.rightAnchor, constant: 10).isActive = true
        replyText.bottomAnchor.constraint(equalTo: replyView.bottomAnchor, constant: -5).isActive = true
        replyText.rightAnchor.constraint(equalTo: replyImageView.leftAnchor).isActive = true
        
        bubbleView.addSubview(imageView)
        imageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 3).isActive = true
        imageView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -3).isActive = true
        imageView.topAnchor.constraint(equalTo: replyView.bottomAnchor,constant: 5).isActive = true
        imageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor,constant: -61).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor,constant: -3).isActive = true
           
        bubbleView.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
           
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: replyView.bottomAnchor, constant: -3).isActive = true
        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
           
        readReceipt.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor,constant: -8).isActive = true
        readReceipt.rightAnchor.constraint(equalTo: bubbleView.rightAnchor,constant: -5).isActive = true
        readReceiptWidth = readReceipt.widthAnchor.constraint(equalToConstant: 19)
        readReceiptWidth!.isActive = true
        readReceipt.heightAnchor.constraint(equalToConstant: 10).isActive = true
           
        msgTime.rightAnchor.constraint(equalTo: readReceipt.leftAnchor,constant: -5).isActive = true
        msgTime.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor,constant: -5).isActive = true
           
    }
       
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
