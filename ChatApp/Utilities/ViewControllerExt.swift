//
//  ViewControllerExt.swift
//  ChatApp
//
//  Created by shubham sharma on 27/06/24.
//

import Foundation
import UIKit

extension UIViewController {

  func presentAlert(withTitle title: String, message : String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default) { action in
        debugPrint("You've pressed OK Button")
    }
    alertController.addAction(OKAction)
    self.present(alertController, animated: true, completion: nil)
  }
}
