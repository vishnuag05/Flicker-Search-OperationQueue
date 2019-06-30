//
//  ImageSizeFetcher.swift
//  Flicker-Search-OperationQueue
//
//  Created by Vishnu Agarwal on 28/06/19.
//  Copyright © 2019 Vishnu Agarwal. All rights reserved.
//

import UIKit

class ImageSizeFetcher: AsynchronousOperation {
    var photo: Photo
    weak var task: URLSessionTask?
    init(_ photo: Photo) {
        self.photo = photo
    }
    override func main() {
        if isCancelled {
            return
        }
        if photo.url != nil {
            self.finish()
            return
        }
        let apiPath = String(format: Api.fetchPhotosSize, Api.apiKeyFlicker, photo.id)
        task = URLSession.shared.dataTask(with: URL(string: apiPath)! ) { [weak self] (data, response, error) in
            if error == nil {
                if let data = data {
                    let decoder = JSONDecoder.init()
                    if let size = try? decoder.decode(SizeMain.self, from: data).correctSize {
                        self?.photo.url = size.source
                        self?.photo.state = PhotoState.sizeFetched
                    }
                } else {
                    //no data
                }
            } else {
                //error
                self?.photo.state = .failed
            }
            self?.finish()
        }
        task?.resume()
    }
    override func cancel() {
        super.cancel()
        task?.cancel()
    }
}
