//
//  FlickrApiClient.swift
//  VirtualTourist
//
//  Created by Saad altwaim on 8/29/21.
//  Copyright © 2021 Saad Altwaim. All rights reserved.
//

import Foundation

class FlickrApiClient
{
    static let apiKey = "fa584c391e63f2965e8226a82d7599c4"
    
    struct LocationVariable
    {
        static var latitude  : Double = 0
        static var longitude : Double = 0
        static var page = Int.random(in: 1..<9)
    }
    
    enum points
    {
        static let baseUrl = "https://www.flickr.com/services/rest/?method=flickr.photos.search"
        static let apiKeyPram = "&api_key=\(FlickrApiClient.apiKey)"
        
        case getFlickrPhotosSearchForLocation
        
        var stringValue : String
        {
            switch self
            {
                case .getFlickrPhotosSearchForLocation :
                    return points.baseUrl + points.apiKeyPram + "&lat=\(LocationVariable.latitude)&lon=\(LocationVariable.longitude)&page=\(LocationVariable.page)&format=json&nojsoncallback=1"
            }
        }
        
        var url : URL
        {
            return URL(string: stringValue)!
        }
    }
    
    //Page 20 Note 3
    class func getFlickrPhotosSearchForLocation(completion : @escaping ([FlickrPhotoArrayResponse] , Error?) -> Void)
    {
//        print("URL : ",points.getFlickrPhotosSearchForLocation.url)
        let task = URLSession.shared.dataTask(with: points.getFlickrPhotosSearchForLocation.url)
        {
            data , response , error in
            guard let Data = data
            else
            {
                completion([],error)
                print("Error IN getFlickrPhotosSearchForLocation")
                print(error!)
                return
            }
            
            do
            {
                let decoder = JSONDecoder()
                let resultObject = try decoder.decode(FlickrPhotoResponse.self, from: Data)
                completion(resultObject.photos.photo, error)
            }
                
            catch
            {
                print(error)
                print("Error IN the catch from getFlickrPhotosSearchForLocation ")
                completion([],error)
            }
        }
        task.resume()
    }
    
    //Page 20 Note 1 / Note 3
    class func downloadAsynchronousImage( imagePath:String, completionHandler: @escaping (_ imageData: Data?, _ errorString: String?) -> Void)
    {
        let session = URLSession.shared
        let imgURL = NSURL(string: imagePath)
        let request: NSURLRequest = NSURLRequest(url: imgURL! as URL)
        let task = session.dataTask(with: request as URLRequest)
        {
            data, response, downloadError in
            if downloadError != nil
            {
                completionHandler(nil, "Could not download image \(imagePath)")
            }
            
            else
            {
                completionHandler(data, nil)
            }
        }
        task.resume()
    }
}
