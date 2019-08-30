//
//  ImageCollectionViewCell.swift
//  ImageGallery
//
//  Created by Abdalla Elsaman on 8/28/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    var cellImage: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    @IBOutlet weak var imageView: UIImageView!
    
}
