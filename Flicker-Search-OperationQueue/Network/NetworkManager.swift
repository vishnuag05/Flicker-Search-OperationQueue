//
//  NetworkManager.swift
//  Flicker-Search-OperationQueue
//
//  Created by Vishnu Agarwal on 27/06/19.
//  Copyright © 2019 Vishnu Agarwal. All rights reserved.
//

import UIKit

class NetworkManager {
    class func getRequest(path: String, success: @escaping(Data) -> Void, failure: @escaping(NSError) -> Void) {
        URLSession.shared.dataTask(with: URLRequest.init(url: URL(string: path.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!)) { (data, response, error) in
            if let error = error {
                failure(error as NSError)
            } else if let data = data {
                success(data)
            }
            }.resume()
    }
}
