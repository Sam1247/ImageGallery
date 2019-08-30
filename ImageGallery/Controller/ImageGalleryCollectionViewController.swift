//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by Abdalla Elsaman on 8/28/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import UIKit

class ImageGalleryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDropDelegate, UICollectionViewDragDelegate {
    
    var imageGallary = ImageGallery() {
        didSet {
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlerForZooming(reconizer:)))
        view.addGestureRecognizer(pinch)
    }
    
    
    // MARK: - Zomming and flow layout
    
    @objc
    func handlerForZooming(reconizer: UIPinchGestureRecognizer) {
        switch reconizer.state {
        case .changed, .ended:
            cellWidth *= reconizer.scale
            reconizer.scale = 1.0
        default:
            break
        }
    }
    
    private var flowLayout: UICollectionViewFlowLayout? {
        return collectionView.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    private var cellWidth: CGFloat = 100 {
        didSet {
            flowLayout?.invalidateLayout()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = imageGallary.imagesData[indexPath.row].aspectRatio * cellWidth
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    // MARK: - segue
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: collectionView.cellForItem(at: indexPath))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let imageVC = segue.destination.contents as? ImageViewController {
            if let pressedCell = sender as? ImageCollectionViewCell {
                imageVC.imageViewBackgroundImage = pressedCell.cellImage
            }
        }
    }
    
    // MARK: - collectionView Delegate
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageGallary.imagesData.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        if let imageCell = cell as? ImageCollectionViewCell {
            let url = imageGallary.imagesData[indexPath.row].url
            let request = URLRequest(url: url.imageURL)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    print(error!)
                }
                if let imageData = data, let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        if let targetIndexpath = collectionView.indexPath(for: imageCell) {
                            if self.imageGallary.imagesData[targetIndexpath.item].url == url {
                                imageCell.cellImage = image
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        if let targetIndexpath = collectionView.indexPath(for: imageCell) {
                            if self.imageGallary.imagesData[targetIndexpath.item].url == url {
                                imageCell.imageView.image = UIImage(named: "fail")
                            }
                        }
                    }
                }
            }
            task.resume()
            return imageCell
        }
        return cell
    }
    
    
    // MARK: - Dropping
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: URL.self) && session.canLoadObjects(ofClass: UIImage.self) || session.localDragSession != nil
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndex = item.sourceIndexPath {
                if let imageData = item.dragItem.localObject as? ImageData {
                    collectionView.performBatchUpdates( {
                        imageGallary.imagesData.remove(at: sourceIndex.item)
                        imageGallary.imagesData.insert(imageData, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndex])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else {
                let placeholderContext = coordinator.drop(
                    item.dragItem,
                    to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "DropPlaceholderCell")
                )
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (provider, error) in
                    if let url = provider as? URL {
                        let request = URLRequest(url: url.imageURL)
                        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                            if error != nil {
                                print(error!)
                            }
                            DispatchQueue.main.async {
                                if let imageData = data, let image = UIImage(data: imageData) {
                                    let aspectRatio = image.size.height / image.size.width
                                    placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                        self.imageGallary.imagesData.insert(ImageData(url: url, aspectRatio: aspectRatio), at: insertionIndexPath.item)
                                    })
                                } else {
                                    placeholderContext.deletePlaceholder()
                                }
                            }
                        }
                        task.resume()
                    }
                }
            }
        }
    }
    
    // MARK: Dragging
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = imageGallary.imagesData[indexPath.item]
        return [dragItem]
    }
}


