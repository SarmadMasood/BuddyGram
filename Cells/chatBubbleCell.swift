//
//  chatBubbleCell.swift
//  BuddyGram
//
//  Created by Mac OSX on 5/1/20.
//  Copyright © 2020 Mac OSX. All rights reserved.
//

import UIKit

@available(iOS 10.0, *)
class chatBubbleCell: UICollectionViewCell {
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
        if message.groupID != nil{
            groupChatVC.presentReplyAction(message: message)
        }else{
            chatLogVC.presentReplyAction(message: message)
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
        if message.groupID != nil{
            groupChatVC.showImage(message: message)
        }else{
            chatLogVC.showImage(message: message)
        }
    }
    
    let readReceipt: UIImageView = {
        let imv = UIImageView()
        imv.backgroundColor = UIColor.clear
        imv.image = UIImage(named: "ReadReceipt")
        imv.translatesAutoresizingMaskIntoConstraints = false
        return imv
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
    var groupAnchor: NSLayoutConstraint?
    var nonGroupAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(msgTime)
        addSubview(readReceipt)
        addSubview(groupUser)
        bubbleView.addSubview(imageView)
        
        imageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        bubbleView.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
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
        
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        groupAnchor = textView.topAnchor.constraint(equalTo: groupUser.bottomAnchor)
        groupAnchor!.isActive = false
        nonGroupAnchor = textView.topAnchor.constraint(equalTo: bubbleView.topAnchor)
        nonGroupAnchor!.isActive = true
        
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
