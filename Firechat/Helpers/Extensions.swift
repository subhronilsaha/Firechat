//
//  Extensions.swift
//  Firechat
//
//  Created by Subhronil Saha on 29/10/19.
//  Copyright © 2019 Subhronil Saha. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
        
    func loadImageUsingCacheUsingUrlString(urlString: String) {
        
        // If image is already in cache, fetch from cache
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            self.image = cachedImage
            return
        }
        
        // Else, download image
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data: data!) {
                    
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    
                    self.image = downloadedImage

                }
                

            }
            }).resume()
        
    }
    
}
