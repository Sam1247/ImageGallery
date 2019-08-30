//
//  ImageGallery.swift
//  ImageGallery
//
//  Created by Abdalla Elsaman on 8/28/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import Foundation

struct ImageGallery {
    var imagesData = [ImageData]()
    private mutating func append(imageData: ImageData) {
        imagesData.append(imageData)
    }
}
