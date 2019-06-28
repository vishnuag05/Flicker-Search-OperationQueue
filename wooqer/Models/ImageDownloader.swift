//
//  ImageDownloader.swift
//  wooqer
//
//  Created by Vishnu Agarwal on 28/06/19.
//  Copyright © 2019 Vishnu Agarwal. All rights reserved.
//

import UIKit

class ImageDownloader: Operation {
    var photo: Photo
    init(_ photo: Photo) {
        self.photo = photo
    }
    override func main() {
        if isCancelled {
            return
        }
        guard let url = photo.url else { return }
        if Caching.shared.cacheImage.object(forKey: url as NSURL) != nil {
            photo.state = .downloaded
            return
        }
        guard let imageData = try? Data(contentsOf: url) else { self.photo.state = .failed ; return }
        if !imageData.isEmpty {
            if let image = UIImage(data:imageData), let url = photo.url {
            Caching.shared.cacheImage.setObject(image, forKey: url as NSURL)
            photo.state = .downloaded
            } else {
                photo.state = .failed
            }
        } else {
            photo.state = .failed
            // handle failure
        }
    }
}
