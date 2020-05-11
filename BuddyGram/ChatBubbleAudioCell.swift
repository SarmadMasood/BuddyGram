//
//  ChatBubbleAudioCell.swift
//  BuddyGram
//
//  Created by Mac OSX on 5/11/20.
//  Copyright © 2020 Mac OSX. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class ChatBubbleAudioCell: UICollectionViewCell, AVAudioPlayerDelegate {
    
    var message: Message!
    let currentUserEmail = Auth.auth().currentUser?.email
    let currentUserPhone = Auth.auth().currentUser?.phoneNumber
    let currentUserUID = Auth.auth().currentUser?.uid
    var soundPlayer : AVAudioPlayer!
    var player: AVPlayer?
    
    let msgTime: UILabel = {
           let label = UILabel()
           label.font = UIFont.systemFont(ofSize: 14)
           label.textColor = UIColor.white
           label.text = "01:19"
           label.translatesAutoresizingMaskIntoConstraints = false
           label.backgroundColor = UIColor.clear
           return label
       }()
       
       let timerLabel: UILabel = {
           let label = UILabel()
           label.text = "01:19"
           label.font = UIFont.systemFont(ofSize: 13)
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
            
            
            setupPlayer()
            player!.play()
        } else {
            player!.pause()
            playPauseButton.setImage(UIImage(named: "Play"), for: .normal)
            NotificationCenter.default.removeObserver(self)
        }
    }
    
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        soundPlayer.stop()
//        playPauseButton.setImage(UIImage(named: "Play"), for: .normal)
//    }
    
    func setupPlayer() {
        var urlPath: URL?
        if message.fromID == currentUserEmail || message.fromID == currentUserPhone {
            if let file = message.fileName {
                urlPath = URL(string: file)
            }
        }else {
            if let url = message.audioURL {
                urlPath = URL(string: url)
            }
        }
        
        
        let playerItem = AVPlayerItem( url: urlPath!)
        player = AVPlayer(playerItem:playerItem)
        player!.rate = 1.0
        player?.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 1), queue: .main, using: { (time) in
            var timeNow = Int(time.value) / Int(time.timescale)

            var currentMins = timeNow / 60
            var currentSec = timeNow % 60

            var timer = String(format: "%02i:%02i", currentMins,currentSec)

            self.timerLabel.text = timer
            
            let duration = playerItem.duration.seconds
            let progress = time.seconds/duration
            //self.slider.maximumValue = Float(playerItem.duration.seconds)
            self.slider.value = Float(progress)
        })
        player?.actionAtItemEnd = .pause
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)),
               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
        
//        do{
//            self.soundPlayer = try AVAudioPlayer(contentsOf: urlPath!)
//            self.soundPlayer.delegate = self
//            self.soundPlayer.prepareToPlay()
//            self.soundPlayer.volume = 1.0
//        } catch {
//            print("error",error)
//        }
           
    }
    
   @objc func playerDidFinishPlaying(note: NSNotification) {
        playPauseButton.setImage(UIImage(named: "Play"), for: .normal)
        slider.value = 0
    
        let duration = message.audioDuration
        var currentMins = Int(duration!) / 60
        var currentSec = Int(duration!) % 60

        var timer = String(format: "%02i:%02i", currentMins,currentSec)

        timerLabel.text = timer
    }
    
    let bubbleView: UIView = {
           let v = UIView()
           v.backgroundColor = UIColor.purple
           v.translatesAutoresizingMaskIntoConstraints = false
           return v
       }()
    
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
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleHeightAnchor: NSLayoutConstraint?
    var bubbleRightAnchor: NSLayoutConstraint?
    var bubbleLeftAnchor: NSLayoutConstraint?
       
    override init(frame: CGRect) {
        super.init(frame: frame)
           
        addSubview(bubbleView)
        addSubview(timerLabel)
        addSubview(msgTime)
        addSubview(timerLabel)
        bubbleView.addSubview(playPauseButton)
           
        bubbleView.addSubview(playPauseButton)
        playPauseButton.leftAnchor.constraint(equalTo: self.bubbleView.leftAnchor, constant: 15).isActive = true
        playPauseButton.topAnchor.constraint(equalTo: self.bubbleView.topAnchor, constant: 7).isActive = true
        playPauseButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        playPauseButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
           
        bubbleView.addSubview(slider)
        slider.leftAnchor.constraint(equalTo: self.playPauseButton.rightAnchor, constant: 10).isActive = true
        slider.heightAnchor.constraint(equalToConstant: 10).isActive = true
       // slider.widthAnchor.constraint(equalToConstant: 150).isActive = true
        slider.rightAnchor.constraint(equalTo: self.bubbleView.rightAnchor, constant: -10).isActive = true
        slider.topAnchor.constraint(equalTo: self.bubbleView.topAnchor, constant: 15).isActive = true
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
           
        msgTime.rightAnchor.constraint(equalTo: bubbleView.rightAnchor,constant: -5).isActive = true
        msgTime.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor,constant: -5).isActive = true
    }
       
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
   
}

//extension ChatBubbleAudioCell {
//    func loadAudioUsingStorageWithUrlString(_ urlString: String) {
//
//        //otherwise fire off a new download
//        let url = URL(string: urlString)
//        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
//
//            //download hit an error so lets return out
//            if error != nil {
//                print(error ?? "")
//                return
//            }
//
//            DispatchQueue.main.async(execute: {
//
//                let localURL = URL(string: self.message.fileName!)
//                do{
//                    try data?.write(to: localURL!)
//                }
//                catch {
//                    print(error)
//                }
//            })
//
//        }).resume()
//    }
//}
