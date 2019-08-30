//
//  ImageDetailView.swift
//  ImageGallery
//
//  Created by Abdalla Elsaman on 8/28/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import UIKit

class ImageDetailView: UIView {

    
    var backgroundImage: UIImage? { didSet { setNeedsDisplay() } }
    
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }
}
