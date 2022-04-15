//
//  FlickrPhotoArrayResponse.swift
//  VirtualTourist
//
//  Created by Saad altwaim on 8/30/21.
//  Copyright © 2021 Saad Altwaim. All rights reserved.
//

import Foundation

struct FlickrPhotoArrayResponse : Codable , Equatable
{
    let id       : String
    let owner    : String
    let secret   : String
    let server   : String
    let farm     : Int
    
    enum CodingKeys : String , CodingKey
    {
        case id
        case owner
        case secret
        case server
        case farm
    }
}
