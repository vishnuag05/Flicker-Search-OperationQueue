//
//  ImageDetailViewController.swift
//  Flicker-Search-OperationQueue
//
//  Created by Vishnu Agarwal on 27/06/19.
//  Copyright © 2019 Vishnu Agarwal. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController {

    let imageViewPhoto: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        // Do any additional setup after loading the view.
    }

    //MARK: - View Setter
    func setUpView() {
        view.backgroundColor = UIColor.white
        imageViewPhoto.pin(to: view, topEdge: 0, bottomEdge: 0, leadingEdge: 0, trailingEdge: 0)
    }
}
