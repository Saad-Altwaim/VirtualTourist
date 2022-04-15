//
//  CollectionViewCell.swift
//  VirtualTourist
//
//  Created by Saad altwaim on 9/10/21.
//  Copyright © 2021 Saad Altwaim. All rights reserved.
//

import UIKit
import Foundation


class CollectionViewCell: UICollectionViewCell 
{
    @IBOutlet weak var imageView: LazyDownloadingImage!  // old cell Code Page 13 - 1  UIImageView!
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        imageView.image = nil
    }
}
