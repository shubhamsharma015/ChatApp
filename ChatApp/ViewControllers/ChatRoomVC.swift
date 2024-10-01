//
//  ChatRoomVC.swift
//  ChatApp
//
//  Created by shubham sharma on 27/06/24.
//

import UIKit
import Firebase
class ChatRoomVC: UIViewController {
    
    
    @IBOutlet weak var userTableView: UITableView!
    @IBOutlet weak var usersImageView: UIImageView!
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    override func viewDidLoad() {
        userTableView.delegate = self
        userTableView.dataSource = self
        setupNavigation()
        fetchUserAndSetupNavBarTitle()
        usersImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUsers)))
        usersImageView.isUserInteractionEnabled = true
        userTableView.allowsMultipleSelectionDuringEditing = true
//        observeMessage()
        observeUserMessage()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let message = self.messages[indexPath.row]
        
        if let chatPartnerId = message.chatPartnerId() {
            Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                
                if let error = error {
                    print("Failed to delete message:", error )
                    return
                }
                
                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadOfTable()
                
//                //this is one way of updating the table, but its actually not that safe..
//                self.messages.removeAtIndex(indexPath.row)
//                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                
            })
        }
    }
    
    
    
    //MARK: Episode 11
    func observeUserMessage() {
        guard let uid = Auth.auth().currentUser?.uid else { return  }
        
        //MARK: ADDED CODE EP 16
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { snapshot in

            let userId = snapshot.key
            print("user id from which current user \(uid) recently had chat = \(snapshot)")
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { snapshot in
                print("messages id = \(snapshot.key)")
                
                let messageId = snapshot.key
                
                self.fetchMessageWithMessageId(messageId: messageId)
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
        // when msg delete from outside and refresh it then
        ref.observe(.childRemoved, with: { snapshot in
            print(snapshot.key)
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
        }, withCancel: nil)
        
    }
    
    private func fetchMessageWithMessageId(messageId: String) {
        
        let messageReference = Database.database().reference().child("messages").child(messageId)
        
        messageReference.observeSingleEvent(of: .value, with: { snapshot in

            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
//                message.setValuesForKeys(dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                    //MARK: moved this two like to the func below on func handleReloadTable()
                }
                //episode 14
                self.attemptReloadOfTable()

            }
        }, withCancel: nil)
    }
    
    // ep 16
    private func attemptReloadOfTable() {
        self.timer?.invalidate()
        print("canceled timer")
        self.timer = Timer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        RunLoop.main.add(self.timer!, forMode: .common)
        print("schedule a table reload timer for 0.1 sec")
    }
    
    var timer: Timer?
    
    @objc func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort { message1, message2 in
            message1.timestamp!.intValue > message2.timestamp!.intValue
        }
        
        DispatchQueue.main.async {
            print("reloading users table view")
            self.userTableView.reloadData()
        }
    }
    
//    func observeMessage() {
//        let ref = Database.database().reference().child("messages")
//        ref.observe(.childAdded, with: { snapShot in
//            if let dictionary = snapShot.value as? [String: AnyObject] {
//                let message = Message(dictionary: dictionary)
////                message.setValuesForKeys(dictionary)
////                self.messages.append(message)
//                if let toId = message.toId {
//                    self.messagesDictionary[toId] = message
//                    self.messages = Array(self.messagesDictionary.values)
//                    self.messages.sort { message1, message2 in
//                        message1.timestamp!.intValue > message2.timestamp!.intValue
//                    }
//                }
//                
//                self.userTableView.reloadData()
//            }
//        }, withCancel: nil)
//    }
    
    func fetchUserAndSetupNavBarTitle(){
        
        if let uID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("users").child(uID).observeSingleEvent(of: .value) { [weak self] snapshot in
                
                guard let strongSelf = self else { return }
                guard let dict = snapshot.value as? [String: AnyObject] else {
                    print("Error in fetching user data")
                    return
                }
                strongSelf.navigationItem.title = dict["name"] as? String
                
            }
            
            
            
        }else {
            print("please login first")
        }
    }
    
    func setupNavigation() {
        navigationItem.hidesBackButton = true
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(handleLogOut)), animated: true)
    }
    
    @objc func handleLogOut(){
        do {
            try Auth.auth().signOut()
            navigationController?.popViewController(animated: true)
        }catch {
            print(error.localizedDescription)
        }
    }
    
    @objc func handleUsers(){
        let usersVC = storyboard?.instantiateViewController(withIdentifier: "UsersViewController") as! UsersViewController
        navigationController?.pushViewController(usersVC, animated: true)
    }
    
}

extension ChatRoomVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userTableView.dequeueReusableCell(withIdentifier: "userTableViewCell") as! userTableViewCell

        cell.message = messages[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else { return }

        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { snapshot in
            debugPrint("opening message of = \(snapshot)")
            guard let dictionary = snapshot.value as? [ String: AnyObject] else { return }
            let user = User()
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
            chatVC.user = user
            self.navigationController?.pushViewController(chatVC, animated: true)
            
            
        }, withCancel: nil)
    }
}
