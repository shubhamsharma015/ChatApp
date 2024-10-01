//
//  ViewController.swift
//  ChatApp
//
//  Created by shubham sharma on 26/06/24.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase

class LoginVC: UIViewController{
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var NameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var loginRegisterSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectprofileImage)))
        profileImageView.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let currentUser = Auth.auth().currentUser {
            navigateToChats()
        }
    }

    func prepareUI(){
        profileImageView.setCornerRadius(radius: profileImageView.bounds.height/2)
        loginRegisterSegment.selectedSegmentIndex = 1
    }
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            print("login")
            segmentIsLogin(true)
        }else {
            print("register")
            segmentIsLogin(false)
        }
    }
    @IBAction func registerBtnAction(_ sender: UIButton) {
        if loginRegisterSegment.selectedSegmentIndex == 0 {
            print("login Btn Pressed")
            loginUser()
        }else {
            debugPrint("Register Btn Pressed")
            registeringUser()
        }
            
    }
    
    func segmentIsLogin(_ isLogin: Bool) {
        NameTF.isHidden = isLogin ? true : false
        registerBtn.setTitle(isLogin ? "Login" : "Register", for: .normal)
        profileImageView.isHidden =  isLogin ? true : false
    }
    
    func registeringUser() {
        if let name = NameTF.text , name.count > 2 {
            if let email = emailTF.text, let pass = passTF.text {
                if email.isValidEmail() {
                    
                    Auth.auth().createUser(withEmail: email, password: pass) {[weak self] user, error in
                        guard let strongSelf = self else { return }
                        if let error = error {
                            strongSelf.presentAlert(withTitle: "Alert", message: "\(error.localizedDescription)")
                        } else if let user = user {
                            print("user register successfully")
                            let unique = NSUUID().uuidString
                            if let profileImage = strongSelf.profileImageView.image {
                                let imgRef = Storage.storage().reference().child("user_Images").child("\(unique).jpg")
//                                if let imageToUpload = profileImage.pngData() {
                                if let imageToUpload = profileImage.jpegData(compressionQuality: 0.1){
                                    imgRef.putData(imageToUpload, metadata: nil) { metaData , error in
                                        if let error = error {
                                            strongSelf.presentAlert(withTitle: "alert", message: error.localizedDescription)
                                        }else {
                                            
                                            imgRef.downloadURL { url, error in
                                                if let error = error {
                                                    print(error.localizedDescription)
                                                }else if let profileString = url?.absoluteString{
                                                    let values = ["name": name, "email": email, "profileImageUrl": profileString]
                                                    strongSelf.registerUserInforeFirebaseWith(uID: user.user.uid, values: values)
                                                }
                                            }
                                        }
                                    }
                                    
                                }else {
                                    strongSelf.presentAlert(withTitle: "Alert", message: "Error to make image to imageData")
                                }
                                
                            }else {
                                strongSelf.presentAlert(withTitle: "Alert", message: "please upload image")
                            }
                            

                        }
                    }
                    
                }else {
                    presentAlert(withTitle: "Alert", message: "Please enter valid email")
                }
            }
        }else {
        presentAlert(withTitle: "Alert", message: "please enter valid name")
        }
    }
    
    func registerUserInforeFirebaseWith(uID: String, values: [String: String]) {
        let ref = Database.database().reference()
        let userReference = ref.child("users").child(uID)

        userReference.updateChildValues(values) { error, ref in
            if let error = error {
                print("error to upload data to database \(error.localizedDescription)")
            }else {
                self.navigateToChats()
            }
            
        }
    }
    
    func loginUser(){
        if let email = emailTF.text, let pass = passTF.text {
            Auth.auth().signIn(withEmail: email, password: pass) { [weak self] result, error in
                if let error = error {
                    self?.presentAlert(withTitle: "Alert", message: error.localizedDescription)
                }else if let result = result {
                    print("login successfull : \(result.description)")
                    self?.navigateToChats(userName: result.user.displayName)
                }
            }

        }
    }
    
    func navigateToChats(userName: String? = nil){
      let chatRoomVC = storyboard?.instantiateViewController(withIdentifier: "ChatRoomVC") as! ChatRoomVC
      navigationController?.pushViewController(chatRoomVC, animated: true)
    }
    
}

extension LoginVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    @objc func handleSelectprofileImage() {
        debugPrint("select image")
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImageView.image = image
        }
        dismiss(animated: true)

    }

}
