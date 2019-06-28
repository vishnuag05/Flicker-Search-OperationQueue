//
//  UIView+Pin.swift
//  wooqer
//
//  Created by Vishnu Agarwal on 27/06/19.
//  Copyright © 2019 Vishnu Agarwal. All rights reserved.
//

import UIKit

extension UIView {
    func pin(to view: UIView, topEdge: CGFloat? = nil, bottomEdge: CGFloat? = nil, leadingEdge: CGFloat? = nil, trailingEdge: CGFloat? = nil, height: CGFloat? = nil, width: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        if let topEdge = topEdge {
            topAnchor.constraint(equalTo: view.topAnchor, constant: topEdge).isActive = true
        }
        if let leadingEdge = leadingEdge {
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leadingEdge).isActive = true
        }
        if let trailingEdge = trailingEdge {
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailingEdge).isActive = true
        }
        if let bottomEdge = bottomEdge {
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottomEdge).isActive = true
        }
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
    }
}
