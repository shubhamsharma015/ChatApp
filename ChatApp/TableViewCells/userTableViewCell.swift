//
//  userTableViewCell.swift
//  ChatApp
//
//  Created by shubham sharma on 30/06/24.
//

import UIKit
import Firebase

class userTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userGmailLbl: UILabel!
    
    var message: Message? {
        didSet {
            setupNameAndProfileImage() 
            userGmailLbl.text = message?.text
            
            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                print("date = \(dateFormatter.string(from: timestampDate as Date))")
            }
        }
    }
    
    private func setupNameAndProfileImage(){
        //MARK: checking that msg is from which user ep = 11
    
        if let toId = message?.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(toId)
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if let dictionary = snapshot.value as? [String: Any] {
                    self.userNameLbl.text = dictionary["name"] as? String
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.userImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                    }
                }
            }, withCancel: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.setCornerRadius(radius: userImageView.bounds.width/2)
        userImageView.setBorder(width: 1, color: .black)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(user: User) {
        userNameLbl.text = user.name
        userGmailLbl.text = user.email
        userImageView.loadImageUsingCacheWithUrlString(urlString: user.profileImageUrl!)
    }
    

}
