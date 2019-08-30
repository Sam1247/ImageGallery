//
//  ImageViewController.swift
//  ImageGallery
//
//  Created by Abdalla Elsaman on 8/28/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 5.0
            scrollView.delegate = self
            scrollView.addSubview(imageDetailView)
        }
    }
    
    var imageViewBackgroundImage: UIImage? {
        get {
            return imageDetailView.backgroundImage
        }
        set {
            scrollView?.zoomScale = 1
            imageDetailView.backgroundImage = newValue
            let size = newValue?.size ?? CGSize.zero
            imageDetailView.frame = CGRect(origin: CGPoint.zero, size: size)
            scrollView?.contentSize = size
            if let dropZone = self.view, size.width > 0, size.height > 0 {
                scrollView?.zoomScale = min(dropZone.bounds.size.width / size.width, dropZone.bounds.size.height / size.height)
            }
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageDetailView
    }
    
    var imageDetailView = ImageDetailView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
