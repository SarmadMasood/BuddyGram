//
//  ReplyBubbleAudioCell.swift
//  BuddyGram
//
//  Created by Mac OSX on 5/25/20.
//  Copyright © 2020 Mac OSX. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

@available(iOS 10.0, *)
class ReplyBubbleAudioCell: UICollectionViewCell {
    var message: Message!
    var chatLogVC: ChatLogViewController!
    var groupChatVC: GroupChatViewController!
    
    let currentUserEmail = Auth.auth().currentUser?.email
    let currentUserPhone = Auth.auth().currentUser?.phoneNumber
    let currentUserUID = Auth.auth().currentUser?.uid
    var player: AVPlayer?
        
        let msgTime: UILabel = {
               let label = UILabel()
               label.font = UIFont.systemFont(ofSize: 13)
               label.textColor = UIColor.white
               label.text = "01:19"
               label.translatesAutoresizingMaskIntoConstraints = false
               label.backgroundColor = UIColor.clear
               return label
           }()
           
           let timerLabel: UILabel = {
               let label = UILabel()
               label.text = "01:19"
               label.font = UIFont.systemFont(ofSize: 12)
               label.textColor = UIColor.darkGray
               label.translatesAutoresizingMaskIntoConstraints = false
               label.backgroundColor = UIColor.clear
               return label
           }()
        
        lazy var playPauseButton: UIButton = {
            let b = UIButton(type: .system)
            b.setImage(UIImage(named: "Play"), for: .normal)
            b.translatesAutoresizingMaskIntoConstraints = false
            b.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            b.tintColor = UIColor.brown
            b.addTarget(self, action: #selector(handelPlay), for: .touchUpInside)
            return b
        }()
        
        
        @objc func handelPlay() {
           
            if playPauseButton.image(for: .normal) == UIImage(named: "Play") {
                playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
                playPauseButton.isHidden = true
                indicator.startAnimating()
                setupPlayer()
            } else {
                player!.pause()
                playPauseButton.setImage(UIImage(named: "Play"), for: .normal)
                NotificationCenter.default.removeObserver(self)
            }
        }
        
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as AnyObject? === player {
            if keyPath == "status" {
                if player!.status == .readyToPlay {
                    playPauseButton.isHidden = false
                    indicator.stopAnimating()
                    player!.play()
                }
            }
        }
    }
        
        func setupPlayer() {
            var urlPath: URL?
            if let url = message.audioURL {
                urlPath = URL(string: url)
            }
            
            let playerItem = AVPlayerItem( url: urlPath!)
            player = AVPlayer(playerItem:playerItem)
            player!.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
            player!.rate = 1.0
            player?.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 1), queue: .main, using: { (time) in
                let timeNow = Int(time.value) / Int(time.timescale)

                let currentMins = timeNow / 60
                let currentSec = timeNow % 60

                let timer = String(format: "%02i:%02i", currentMins,currentSec)

                self.timerLabel.text = timer
                
                let duration = playerItem.duration.seconds
                let progress = time.seconds/duration
                //self.slider.maximumValue = Float(playerItem.duration.seconds)
                self.slider.value = Float(progress)
            })
            player?.actionAtItemEnd = .pause
            
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)),
                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
               
        }
        
       @objc func playerDidFinishPlaying(note: NSNotification) {
            playPauseButton.setImage(UIImage(named: "Play"), for: .normal)
            slider.value = 0
        
        let currentMins = Int(message.audioDuration!) / 60
        let currentSec = Int(message.audioDuration!) % 60

            let timer = String(format: "%02i:%02i", currentMins,currentSec)
            timerLabel.text = timer
        }
        
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
        
        let slider: UISlider = {
           let s = UISlider()
            s.contentScaleFactor = 10
            s.value = 0
            s.minimumTrackTintColor = UIColor.brown
            s.tintColor = UIColor.white
            s.thumbTintColor = UIColor.brown
            s.translatesAutoresizingMaskIntoConstraints = false
            return s
        }()
        
        let readReceipt: UIImageView = {
            let imv = UIImageView()
            imv.backgroundColor = UIColor.clear
            imv.image = UIImage(named: "ReadReceipt")
            imv.translatesAutoresizingMaskIntoConstraints = false
            return imv
        }()
        
        let indicator: UIActivityIndicatorView = {
            let ind = UIActivityIndicatorView()
            ind.translatesAutoresizingMaskIntoConstraints = false
            ind.hidesWhenStopped = true
            return ind
        }()
    
        let replyView: UIView = {
              let view = UIView()
              view.translatesAutoresizingMaskIntoConstraints = false
              view.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 0.15)
              view.layer.cornerRadius = 7
              view.clipsToBounds = true
              return view
          }()
          
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
            addSubview(timerLabel)
            addSubview(msgTime)
            addSubview(readReceipt)
            addSubview(timerLabel)
            addSubview(groupUser)
            
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
               
            bubbleView.addSubview(playPauseButton)
            playPauseButton.leftAnchor.constraint(equalTo: self.bubbleView.leftAnchor, constant: 15).isActive = true
            playPauseButton.topAnchor.constraint(equalTo: self.replyView.bottomAnchor, constant: 7).isActive = true
            playPauseButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
            playPauseButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            bubbleView.addSubview(indicator)
            indicator.leftAnchor.constraint(equalTo: self.bubbleView.leftAnchor, constant: 15).isActive = true
            indicator.topAnchor.constraint(equalTo: self.replyView.bottomAnchor, constant: 7).isActive = true
            indicator.widthAnchor.constraint(equalToConstant: 20).isActive = true
            indicator.heightAnchor.constraint(equalToConstant: 20).isActive = true
               
            bubbleView.addSubview(slider)
            slider.leftAnchor.constraint(equalTo: self.playPauseButton.rightAnchor, constant: 10).isActive = true
            slider.heightAnchor.constraint(equalToConstant: 10).isActive = true
            slider.rightAnchor.constraint(equalTo: self.bubbleView.rightAnchor, constant: -10).isActive = true
            slider.topAnchor.constraint(equalTo: self.replyView.bottomAnchor, constant: 15).isActive = true
            slider.centerYAnchor.constraint(equalTo: self.playPauseButton.centerYAnchor).isActive = true
            
            bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor,constant: -8)
            bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: self.leftAnchor,constant: 8)
            bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
            bubbleWidthAnchor?.isActive = true
            bubbleHeightAnchor = bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor)
            bubbleHeightAnchor?.isActive = true
            bubbleView.layer.cornerRadius = 10
            
            timerLabel.centerXAnchor.constraint(equalTo: self.playPauseButton.centerXAnchor).isActive = true
            timerLabel.bottomAnchor.constraint(equalTo: self.bubbleView.bottomAnchor, constant: -5).isActive = true
               
           readReceipt.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor,constant: -8).isActive = true
           readReceipt.rightAnchor.constraint(equalTo: bubbleView.rightAnchor,constant: -5).isActive = true
           readReceiptWidth = readReceipt.widthAnchor.constraint(equalToConstant: 19)
            readReceiptWidth?.isActive = true
           readReceipt.heightAnchor.constraint(equalToConstant: 10).isActive = true
           
           msgTime.rightAnchor.constraint(equalTo: readReceipt.leftAnchor,constant: -5).isActive = true
           msgTime.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor,constant: -5).isActive = true
            
        }
           
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
}
