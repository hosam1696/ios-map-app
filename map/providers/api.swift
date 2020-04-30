//
//  api.swift
//  map
//
//  Created by Hosam Elnabawy on 4/30/20.
//  Copyright © 2020 Hosam Elnabawy. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

class FlickerApi {
    

    private let API_KEY = "ebf3d8e46330734a8aca59fee2b4d565"
    private let API_SECRET = "c7cdb8b249a8d78e"
    private(set) var url: String = ""
    var annotation: DroppablePin {
        didSet {
            getFlickerUrl()
        }
    }
    var radiusInKm = 1
    var numberOfImages = 10
    var imagesUrls: [String] = []
    var images: [UIImage] = []
    var imageLoadCount: String {
        get {
            return "\(images.count)/\(numberOfImages)"
        }
    }
    
    
    init(annotation: DroppablePin, numberOfImages: Int, radiusInKm: Int) {
        self.radiusInKm = radiusInKm
        self.numberOfImages = numberOfImages
        self.annotation = annotation
        getFlickerUrl()
    }
    
    
    func setAnnotation(annotation: DroppablePin) {
        self.annotation = annotation
    }
    
    private func getFlickerUrl() {
        self.url = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=\(radiusInKm)&radius_units=km&format=json&nojsoncallback=1&per_page=\(numberOfImages)"
    }
    
    
    func getUrls(handler: @escaping (_ status: Bool) -> Void) {
        AF.request(self.url).responseJSON { response in
//            print("getting Urls Data...")
            print(self.url)
            self.imagesUrls = []
            switch response.result {
                
                case .success:
                    guard let json = response.value as? Dictionary<String, AnyObject> else {
                        handler(false)
                        return
                    }
                    let photosHolder = json["photos"] as! Dictionary<String, AnyObject>
                    let photos = photosHolder["photo"] as! [Dictionary<String, AnyObject>]
                    
                    photos.forEach { (photo) in
                        let url = "https://live.staticflickr.com/\(photo["server"] as! String)/\(photo["id"] as! String)_\(photo["secret"] as! String)_m.jpg"
                        self.imagesUrls.append(url)
                    }

//                    print(self.imagesUrls)
                    handler(true)
                case.failure:
                        print("Error getting Data")
                        handler(false)
            }
            
        }
    }
    
    func loadImages(handler: @escaping (_ status: Any) -> Void) {

        images = []
        for imageUrl in imagesUrls {
            AF.request(imageUrl).responseImage { (response) in
                switch response.result {
                case .failure:
                    handler("Faild to Load Image")
                case .success(let image):
                    self.images.append(image)
                    handler(image)
                }
            }
        }
    }
    
    
    func cancelSessions() {
        
    }
    
}
