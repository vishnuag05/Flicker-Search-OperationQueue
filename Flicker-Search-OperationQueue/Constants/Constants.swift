
//
//  Constants.swift
//  Flicker-Search-OperationQueue
//
//  Created by Vishnu Agarwal on 27/06/19.
//  Copyright © 2019 Vishnu Agarwal. All rights reserved.
//

import Foundation

struct Api {
    //add your key which you can get from flicker
    static let apiKeyFlicker = "3275614c71d8ee38565a76d57f4c2f9a"
    static let fetchPhotos = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=%@&format=json&nojsoncallback=1&page=%d"
    static let fetchPhotosSize = "https://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=%@&photo_id=%@&format=json&nojsoncallback=1"
}
