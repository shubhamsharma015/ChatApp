//
//  UsersViewController.swift
//  ChatApp
//
//  Created by shubham sharma on 30/06/24.
//

import UIKit
import Firebase

class UsersViewController: UIViewController {
    

    @IBOutlet weak var usersTableView: UITableView!
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersTableView.delegate = self
        usersTableView.dataSource = self
        navigationItem.backButtonTitle = "Back"
        navigationItem.title = "Users"
        fetchUsers()
    }
    
    
    func fetchUsers(){
        
        Database.database().reference().child("users").observe(.childAdded, with: { [weak self] snapshot in
            if let dictionary = snapshot.value as? [String: String] {
                let user = User()
                user.id = snapshot.key
                user.setValuesForKeys(dictionary)
                self?.users.append(user)
                self?.usersTableView.reloadData()
                
            }
        }, withCancel: nil)

    }


}

extension UsersViewController:  UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userTableViewCell") as! userTableViewCell
        let user = users[indexPath.row]
        cell.configureCell(user: user)
        cell.selectionStyle = .none

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        chatVC.user = self.users[indexPath.row]
        navigationController?.pushViewController(chatVC, animated: true)
        
    }
}
