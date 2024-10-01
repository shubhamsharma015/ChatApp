//
//  ChatVC.swift
//  ChatApp
//
//  Created by shubham sharma on 02/07/24.
//

import UIKit
import Firebase
import UniformTypeIdentifiers
import AVFoundation


class ChatVC: UIViewController{

    @IBOutlet weak var messagesCollectionView: UICollectionView!
    @IBOutlet weak var inputTF: UITextField!
    @IBOutlet weak var ContainerViewBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var msgSendBtn: UIButton! {
        didSet {
            msgSendBtn.setCornerRadius(radius: 20)
        }
    }
    
    var startingFrame : CGRect?
    var blackBackgroundView: UIView?
    
    var messages = [Message]()
    let cellId = "cellid"
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    func observeMessages(){
        guard let uid = Auth.auth().currentUser?.uid,let toId = user?.id else { return  }
        
        let userMessageRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessageRef.observe(.childAdded, with: { snapshot in
            //got message id's
            
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { snapshot in
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                
                let message = Message(dictionary: dictionary)
//                message.setValuesForKeys(dictionary)
                
//                if message.chatPartnerId() == self.user?.id {
                    print("messages --------------- \n \(message.text)")
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.messagesCollectionView.reloadData()
                        
                        let indexPath = IndexPath(item: self.messages.count-1, section: 0)
                        self.messagesCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
                        
                    }
//                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.delegate = self
        messagesCollectionView.dataSource = self
//        messagesCollectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 5, right: 0)
//        messagesCollectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
//        messagesCollectionView.alwaysBounceVertical = true
//        
//        setUpKeyboardObservers()
//        
//        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
//        uploadImageView.isUserInteractionEnabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //for memory leak ep = 15
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        messagesCollectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 5, right: 0)
        messagesCollectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        messagesCollectionView.alwaysBounceVertical = true
        
        setUpKeyboardObservers()
        
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        uploadImageView.isUserInteractionEnabled = true
    }

    
    //MARK: if want to know more see ep 16
    
    @IBAction func sendBtnAction(_ sender: UIButton) {

        let properties = ["text": inputTF.text] as [String : AnyObject]
        sendMessageWithProperties(properties: properties)
        
        
    }
    
    func setUpKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        
        print(keyboardFrame?.height)
        ContainerViewBottomAnchor.constant = (keyboardFrame?.height ?? 300)
        UIView.animate(withDuration: keyboardDuration ?? 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleKeyboardWillHide(notification: NSNotification) {
        ContainerViewBottomAnchor.constant = 0
        
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        
        UIView.animate(withDuration: keyboardDuration ?? 0.1) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc func handleKeyboardDidShow(){
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count-1, section: 0)
            messagesCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [UTType.image.identifier, UTType.movie.identifier]

       present(imagePickerController, animated: true, completion: nil)
    }
    
}


extension ChatVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = messagesCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        cell.textView.text = nil
        cell.messageImageView.image = nil

        
        
        
        let message = messages[indexPath.item]
        cell.chatVC = self
        cell.message = message
        cell.textView.text = message.text
        

        setupCell(cell: cell, message: message)
        
        //MARK: bubble width
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        }else if message.imageUrl != nil {
            // when cell is image type
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        cell.playButton.isHidden = message.videoUrl == nil
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
        
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
    
        if message.fromId == Auth.auth().currentUser?.uid {
// Outgoing msg bubble
            cell.bubbleView.backgroundColor = UIColor.blue
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            
            cell.bubbelViewRightAnchor?.isActive = true
            cell.bubbelViewLeftAnchor?.isActive = false
        } else {
            // Incoming msg bubble
            cell.bubbleView.backgroundColor = UIColor.lightGray
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            
            cell.bubbelViewRightAnchor?.isActive = false
            cell.bubbelViewLeftAnchor?.isActive = true
        }
        
        if let messageImageUrl = message.imageUrl {
        
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            //--
            guard let image = cell.messageImageView.image else { return }
            let resizedImage = self.resizeImage(image: image, targetSize: CGSize(width: 200, height: 200))
            cell.messageImageView.image = resizedImage
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .black
        }else {
            cell.messageImageView.isHidden = true
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]

        if let text = message.text {
            height = estimateFrameForText(text: text).height + 20

        }else if let imageWidth = message.imageWidth?.floatValue,let imageHeight = message.imageHeight?.floatValue {

            //h1 / w1 = h2 / w2
            // solve for h1
            // h1 = h2 / w2 * w1
            
            height = CGFloat(imageHeight / imageWidth * 200)

        }
        
        let width = UIScreen.main.bounds.width

        return CGSize(width: width, height: height)
    }


    //MARK: for the size of cell according to text
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        messagesCollectionView.collectionViewLayout.invalidateLayout()
    }
}

extension ChatVC: UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL {
            print("selected video url ",videoUrl)
            handleVideoSelectedForUrl(url: videoUrl)
        } else {
            handleImageSelectedForInfo(info: info)
        }
        dismiss(animated: true)
    }
    
    private func handleVideoSelectedForUrl(url: NSURL) {
        let filename = UUID().uuidString + ".mov"
        
        // Reference to Firebase storage
        let storageRef = Storage.storage().reference().child("message_movies").child(filename)
        
        // Upload video file to Firebase
    
        let uploadTask = storageRef.putFile(from: url as URL,metadata: nil) { metadata , error in
            
            if let error = error {
                print("Failed upload of video:", error.localizedDescription)
                return
            }
            
            storageRef.downloadURL { (url: URL?, error: Error?) in
                if let error = error {
                    print("Failed to retrieve download URL:", error.localizedDescription)
                    return
                }
                
                if let videoUrl = url?.absoluteString, let thumbnailImage = self.thumbnailImageForFileUrl(fileUrl: url!) {
                     
                        self.uploadToFirebaseStorageUsingImage(image: thumbnailImage) { (imageUrl: String) in
                            self.addingPropertiesWith(imageUrl: imageUrl, thumbnailImage: thumbnailImage, videoUrl: videoUrl)
                      
                        }
                }
            }
        }
        // Observe upload progress
        uploadTask.observe(.progress) { (snapshot) in
            if let compleedUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(compleedUnitCount)
            }
        }
        // Observe successful upload
        uploadTask.observe(.success) { snapshot in
            self.navigationItem.title = self.user?.name
        }

        uploadTask.observe(.failure) { snapshot in
            print(snapshot.description)
        }
        uploadTask.observe(.unknown) { snapshot in
            print(snapshot.description)
        }
    }

    private func addingPropertiesWith(imageUrl: String,thumbnailImage: UIImage,videoUrl: String){
        let properties = ["imageUrl": imageUrl, "imageWidth": thumbnailImage.size.width, "imageHeight": thumbnailImage.size.height, "videoUrl": videoUrl] as [String: AnyObject]
        sendMessageWithProperties(properties: properties)
    }
    
    private func thumbnailImageForFileUrl(fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
        
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
            
        } catch let err {
            print(err)
        }
        
        return nil
    }
    
    private func handleImageSelectedForInfo(info: [UIImagePickerController.InfoKey: Any]) {
        
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        }else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(image: selectedImage, completion: { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl: imageUrl, image: selectedImage)
            })
        }
        
    }
    
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage, completion: @escaping (_ imageUrl: String) -> ()){
        print("upload to firebase")
        let imageName = NSUUID().uuidString

        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = image.jpegData(compressionQuality: 0.2){
            ref.putData(uploadData, metadata: nil) { metadata, error in
                if error != nil {
                    print("failed to upload image: ", error)
                }
                
                ref.downloadURL { url,error in
                    if let error = error {
                        print("error in getting image url")
                        return
                    }else if let imageUrl = url?.absoluteString {
                        print("image url :",imageUrl)
                        completion(imageUrl)
//                        self.sendMessageWithImageUrl(imageUrl: imageUrl,image: image)
                    }
                }
                
            }

        }
        
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        
        let properties = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height] as [String : AnyObject]
        
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithProperties( properties: [String: AnyObject]){
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970) as NSNumber
        if let toId = user?.id, let fromId = Auth.auth().currentUser?.uid {
            var values = ["toId": toId, "fromId": fromId, "timestamp":timestamp] as [String : AnyObject]
            
            //appending extra perameters
            // Key $0, Value $1
            properties.forEach({values[$0] = $1})
            
            
            childRef.updateChildValues(values) { error , ref in
                if let error = error {
                    print("errro in updating value \(error.localizedDescription)")
                }
                self.inputTF.text = nil
                if let messageId = childRef.key {
                    let userMessageRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
                    userMessageRef.updateChildValues([messageId: 1])
                    
                    let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
                    recipientUserMessagesRef.updateChildValues([messageId: 1])
                }

                
            }
            
            
        }

    }
    
}

//MARK: custom zomming function
extension ChatVC {
    func performZoomInForStaringImageView(startingImageView: UIImageView) {
        print("Zooming looginc ")
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        print(startingFrame ?? "000")
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            blackBackgroundView = UIView(frame: window.frame)
            blackBackgroundView?.backgroundColor = .black
            blackBackgroundView?.alpha = 0
            window.addSubview(blackBackgroundView!)
            
            window.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,options: .curveEaseOut) {
                
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                
                // h2 / w1 = h1 / w1
                // h2 = h1 / w1 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * window.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height:height )
                zoomingImageView.center = window.center

            } completion: { completed in
//                zoomOutImageView.removeFromSuperview()

            }
                    
            
        }

    }
    
    @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer){

        if let zoomOutImageView = tapGesture.view {
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,options: .curveEaseOut) {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
            } completion: { completed in
                zoomOutImageView.removeFromSuperview()
                
            }

        }
    }
}
extension ChatVC {
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)
        let scaledImageSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        UIGraphicsBeginImageContextWithOptions(scaledImageSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage ?? image
    }
}
