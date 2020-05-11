//
//  chatBubbleCell.swift
//  BuddyGram
//
//  Created by Mac OSX on 5/1/20.
//  Copyright © 2020 Mac OSX. All rights reserved.
//

import UIKit

class chatBubbleCell: UICollectionViewCell {
    var message: Message!
    
    let playButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(named: "PlayButton"), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.tintColor = UIColor.darkGray
        b.isUserInteractionEnabled = false
        return b
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.text = "Sample text for now"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
        tv.isScrollEnabled = false
        return tv
    }()
    
    let msgTime: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        return label
    }()
    
    let bubbleView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.purple
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let imageView: UIImageView = {
        let imv = UIImageView()
        imv.backgroundColor = UIColor.clear
        imv.contentMode = .scaleAspectFill
        imv.layer.cornerRadius = 10
        imv.layer.masksToBounds = true
        imv.translatesAutoresizingMaskIntoConstraints = false
        return imv
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleHeightAnchor: NSLayoutConstraint?
    var bubbleRightAnchor: NSLayoutConstraint?
    var bubbleLeftAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(msgTime)
        bubbleView.addSubview(imageView)
        
        
        imageView.leftAnchor.constraint(equalTo: self.bubbleView.leftAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: self.bubbleView.widthAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: self.bubbleView.topAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: self.bubbleView.heightAnchor).isActive = true
        
        bubbleView.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: self.bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: self.bubbleView.centerYAnchor).isActive = true
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
        
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        msgTime.rightAnchor.constraint(equalTo: bubbleView.rightAnchor,constant: -5).isActive = true
        msgTime.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor,constant: -5).isActive = true
 }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
