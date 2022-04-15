//
//  FlickrPhotoInfoResponse.swift
//  VirtualTourist
//
//  Created by Saad altwaim on 8/30/21.
//  Copyright © 2021 Saad Altwaim. All rights reserved.
//

import Foundation

struct FlickrPhotoInfoResponse : Codable , Equatable
{
    let page    : Int
    let pages   : Int
    let total   : Int
    let photo   : [FlickrPhotoArrayResponse]
    
    enum CodingKeys : String , CodingKey
    {
        case page
        case pages
        case total
        case photo
    }
    
}
