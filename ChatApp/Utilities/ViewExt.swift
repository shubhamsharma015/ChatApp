//
//  ViewExt.swift
//  ChatApp
//
//  Created by shubham sharma on 27/06/24.
//

import UIKit

extension UIView {
//    func applyHorizontalGradient() {
//        let startClr = UIColor(hexString: "06D7DF").cgColor
//        let endClr = UIColor(hexString: "F44FF8").cgColor
//        
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [startClr,endClr]
//        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
//        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
//        gradientLayer.frame = self.bounds
//        self.layer.insertSublayer(gradientLayer, at: 0)
//    }
    
    func setBorder(width: CGFloat, color: UIColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
    
    func setCornerRadius(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    

}
