//
//  LazyDownloadingImage.swift
//  VirtualTourist
//
//  Created by Saad altwaim on 9/19/21.
//  Copyright © 2021 Saad Altwaim. All rights reserved.
//

import Foundation
import UIKit

class LazyDownloadingImage : UIImageView
{
    private let imageCache = NSCache<AnyObject , UIImage>() // Page 12 note 1
    
    func loadImage(fromURL imageURL : URL , placeHolderImage : String , button : UIButton)
    {
        self.image = UIImage(named : placeHolderImage) // Page 12 note 4
        
        if let cachedImage = self.imageCache.object(forKey : imageURL as AnyObject) // Page 12 note 2
        {
            debugPrint("image are loaded from cache for = \(imageURL)")
            self.image = cachedImage
            
            return
        }
        
        let queue = DispatchQueue.global()
        var item: DispatchWorkItem? // Page 14 Note 1
        
        item = DispatchWorkItem
        {
            [weak self] () -> Void in // Page 13 note 2
            if let iamgeData = try? Data(contentsOf : imageURL)
            {
                debugPrint("image downloaded from server")
                if let image = UIImage(data : iamgeData)
                {
                    self?.imageCache.setObject(image , forKey : imageURL as AnyObject) // Page 12 note 3
                    DispatchQueue.main.async
                    {
                        self?.image = image // Page 12 note 5
                        button.isEnabled = true
                    }
                }
            }
        }
        
        /// To save the Device sources
        queue.async(execute: item!) // Page 14 note 2
        queue.asyncAfter(deadline: .now() + 0.5) // Page 14 note 3
        {
            item?.cancel()
            item = nil
            self.imageCache.removeAllObjects()
        }
    }
}
