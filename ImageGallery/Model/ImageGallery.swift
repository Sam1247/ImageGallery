//
//  ImageGallery.swift
//  ImageGallery
//
//  Created by Abdalla Elsaman on 8/28/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import Foundation

class ImageGallery {
    var name: String
    var imagesData = [ImageData]()
    init(name: String) {
        self.name = name
    }
    private func append(imageData: ImageData) {
        imagesData.append(imageData)
    }
}
