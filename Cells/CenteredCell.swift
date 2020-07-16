//
//  CenteredCell.swift
//  BuddyGram
//
//  Created by Sarmad on 12/07/2020.
//  Copyright © 2020 Mac OSX. All rights reserved.
//

import UIKit

@available(iOS 10.0, *)
class CenteredCell: UICollectionViewCell {
    var message: Message!
    
    let textView: UITextView = {
           let tv = UITextView()
           tv.isEditable = false
           tv.text = "Sample text for now"
           tv.font = UIFont.systemFont(ofSize: 16)
           tv.translatesAutoresizingMaskIntoConstraints = false
           tv.backgroundColor = UIColor.clear
           tv.textColor = UIColor.gray
           tv.isScrollEnabled = false
           tv.isSelectable = false
           tv.isUserInteractionEnabled = false
           tv.textAlignment = .center
           return tv
       }()
       
       lazy var bubbleView: UIView = {
           let v = UIView()
           v.backgroundColor = UIColor(red: 254/255, green: 244/255, blue: 197/255, alpha: 1.0)
           v.translatesAutoresizingMaskIntoConstraints = false
           v.isUserInteractionEnabled = true
           return v
       }()
       
       var bubbleWidthAnchor: NSLayoutConstraint?
       var bubbleHeightAnchor: NSLayoutConstraint?
       
       override init(frame: CGRect) {
           super.init(frame: frame)
           
           addSubview(bubbleView)
           addSubview(textView)
           
           bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
           bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
           bubbleWidthAnchor?.isActive = true
           bubbleHeightAnchor = bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor)
           bubbleHeightAnchor?.isActive = true
           bubbleView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
           bubbleView.layer.cornerRadius = 10
           
          // textView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
           textView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
           textView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
           textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
           textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
           
    }
       
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
