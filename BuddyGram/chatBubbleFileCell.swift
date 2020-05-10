//
//  chatBubbleFileCell.swift
//  BuddyGram
//
//  Created by Mac OSX on 5/9/20.
//  Copyright © 2020 Mac OSX. All rights reserved.
//

import UIKit

class chatBubbleFileCell: UICollectionViewCell {
    let msgTime: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        return label
    }()
    
    let extLabel: UILabel = {
        let label = UILabel()
        label.text = ".ext"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        return label
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "filename.ext"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.darkGray
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
        imv.image = UIImage(named: "file")
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
        addSubview(msgTime)
        bubbleView.addSubview(imageView)
        bubbleView.addSubview(nameLabel)
        imageView.addSubview(extLabel)
        
        extLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        extLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        
        imageView.leftAnchor.constraint(equalTo: self.bubbleView.leftAnchor,constant: 10).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.bubbleView.centerYAnchor).isActive = true
        
        nameLabel.centerYAnchor.constraint(equalTo: self.bubbleView.centerYAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 10).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -8).isActive = true
        
        bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor,constant: -8)
        bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: self.leftAnchor,constant: 8)
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleHeightAnchor = bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor)
        bubbleHeightAnchor?.isActive = true
        bubbleView.layer.cornerRadius = 10
        
        msgTime.rightAnchor.constraint(equalTo: bubbleView.rightAnchor,constant: -5).isActive = true
        msgTime.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor,constant: -5).isActive = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
