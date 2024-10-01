//
//  ImageViewExt.swift
//  ChatApp
//
//  Created by shubham sharma on 01/07/24.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func loadImageUsingCacheWithUrlString(urlString: String) {
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        if let url = NSURL(string: urlString) as? URL {
            URLSession.shared.dataTask(with: url) { data, response , error in
                if let error = error {
                    print(error.localizedDescription)
                }else if let data = data {
                    DispatchQueue.main.async {
                        
                        if let downloadedImg = UIImage(data: data){
                            imageCache.setObject(downloadedImg, forKey: urlString as NSString)
                            self.image = downloadedImg
                        }
                        

                    }
                }
            }.resume()
        }else {
            print("error to convert image string to url")
        }
    }
}
