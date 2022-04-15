//
//  FlickrPhotoResponse.swift
//  VirtualTourist
//
//  Created by Saad altwaim on 8/29/21.
//  Copyright © 2021 Saad Altwaim. All rights reserved.
//

import Foundation
 

struct FlickrPhotoResponse :Codable , Equatable
{
    let photos : FlickrPhotoInfoResponse
    let stat   : String
    
    enum CodingKeys : String , CodingKey
    {
        case photos
        case stat
    }
}
  

