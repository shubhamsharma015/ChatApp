//
//  ChatMessageCell.swift
//  ChatApp
//
//  Created by shubham sharma on 31/07/24.
//

import UIKit
import AVFoundation

class ChatMessageCell: UICollectionViewCell {
    
    var message: Message?
    var chatVC: ChatVC?
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .large)
        aiv.color = .white
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "play")
        button.tintColor = UIColor.white
        button.setImage(image, for: .normal)
        
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        
        return button
    }()
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    @objc func handlePlay() {
        print("play btn clicked")
        if let videoUrlString = message?.videoUrl, let url = NSURL(string: videoUrlString) {
            player = AVPlayer(url: url as URL)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            
            player?.play()
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
            
            print("Attempting to play video......???")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "Sample text fro now"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.textColor = .white
        tv.isEditable = false
        return tv
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 137, blue: 249, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setCornerRadius(radius: 16)
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        //        imageView.image = UIImage(systemName: "person.fill")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setCornerRadius(radius: 15)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setCornerRadius(radius: 15)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        
        imageView.isUserInteractionEnabled = true
        
        
        return imageView
    }()
    
    @objc func handleZoomTap(_ tapGesture: UITapGestureRecognizer){

        if let imageView = tapGesture.view as? UIImageView {
            self.chatVC?.performZoomInForStaringImageView(startingImageView: imageView)
        }
    }
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbelViewRightAnchor: NSLayoutConstraint?
    var bubbelViewLeftAnchor: NSLayoutConstraint?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        
        bubbleView.addSubview(messageImageView)
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
//        messageImageView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        messageImageView.addGestureRecognizer(UITapGestureRecognizer(target: self , action: #selector(handleZoomTap)))
        
        bubbleView.addSubview(playButton)
        //x,y,w,h
        playButton.centerXAnchor.constraint(equalTo:bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo:bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant:50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant:50).isActive = true
        
        bubbleView.addSubview(activityIndicatorView)
        //x,y,w,h
        activityIndicatorView.centerXAnchor.constraint(equalTo:bubbleView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo:bubbleView.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant:50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant:50).isActive = true
        
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        //Bubble View --
        bubbelViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbelViewRightAnchor?.isActive = true
        
        bubbelViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor,constant: 8)
        bubbelViewLeftAnchor?.isActive = false
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        
        // TextView --
        
//        textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor,constant: 8).isActive = true
        
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
       
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
