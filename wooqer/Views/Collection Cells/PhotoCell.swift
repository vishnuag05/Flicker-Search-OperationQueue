//
//  PhotoCollectionViewCell.swift
//  wooqer
//
//  Created by Vishnu Agarwal on 27/06/19.
//  Copyright © 2019 Vishnu Agarwal. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    let imageViewPhoto: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    //MARK: - Setters
    func setUpViews() {
        imageViewPhoto.pin(to: contentView, topEdge: 0, bottomEdge: 0, leadingEdge: 0, trailingEdge: 0)
        imageViewPhoto.image = #imageLiteral(resourceName: "placeholder")
    }
}
