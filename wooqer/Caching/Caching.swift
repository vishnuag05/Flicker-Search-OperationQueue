//
//  Caching.swift
//  wooqer
//
//  Created by Vishnu Agarwal on 28/06/19.
//  Copyright © 2019 Vishnu Agarwal. All rights reserved.
//

import UIKit

class Caching {
    let cacheImage = NSCache<NSURL, UIImage>()
    static let shared: Caching = {
        let caching = Caching()
        // set the limit if you want your app to use less memory in case its already using memory though this is by default managed as well, you don't even need to set
        caching.cacheImage.countLimit = 200
        return caching
    }()
}
