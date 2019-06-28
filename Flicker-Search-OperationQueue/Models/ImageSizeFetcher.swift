//
//  ImageSizeFetcher.swift
//  Flicker-Search-OperationQueue
//
//  Created by Vishnu Agarwal on 28/06/19.
//  Copyright © 2019 Vishnu Agarwal. All rights reserved.
//

import UIKit

class ImageSizeFetcher: Operation {
    var photo: Photo
    init(_ photo: Photo) {
        self.photo = photo
    }
    override func main() {
        if isCancelled {
            return
        }
        let apiPath = String(format: Api.fetchPhotosSize, Api.apiKeyFlicker, photo.id)
        URLSession.shared.dataTask(with: URL(string: apiPath)! ) { (data, response, error) in
            if error == nil {
                if let data = data {
                    let decoder = JSONDecoder.init()
                    if let size = try? decoder.decode(SizeMain.self, from: data).correctSize {
                        self.photo.url = size.source
                        self.photo.state = PhotoState.sizeFetched
                    }
                } else {
                    //no data
                }
            } else {
                //error
                self.photo.state = .failed
            }
        }.resume()
    }
}
