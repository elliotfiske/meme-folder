//
//  RecentPhotosCollectionViewController.swift
//  memefolder
//
//  Created by Elliot Fiske on 2/14/21.
//  Copyright © 2021 Meme Folder. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "Cell"
private let headerReuseIdentifier = "header"

//
// Elliot is still trying to figure out the best way to set this up with xibs, storyboards and nonsense.
//  My current solution has RecentPhotos controller as a regular view controller, because I need a header
//  view but I don't trust the built in "supplementary view" system to be what I need.
//
// To get around this, we have a strange setup where I've essentially copied the same collectionView and
//  collectionViewLayout properties you would see on a UICollectionViewController, but stuck them on the
//  UIViewController you see below. I'll be able to do whatever nonsense I want with the header, like
//  making it fixed or swipe away or whatever.
//
// The RecentPhotosCollectionViewController.xib has this file as its "File's Owner" which lets me make outlets
//  from there to here.
//

class RecentPhotosCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    fileprivate let cachingManager = PHCachingImageManager()
    
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var thumbnailSize = CGSize.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView.register(UINib(nibName: "ImageCell", bundle: .main), forCellWithReuseIdentifier: reuseIdentifier)
        
        PhotoModel.shared.getRecentPhotos()
            .subscribe(onNext: {
                [weak self] _ in
                self?.collectionView.reloadData()
            })
            .disposed(by: rx.disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let scale = UIScreen.main.scale
        let cellSize = collectionViewLayout.itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return PhotoModel.shared.allPhotosFetchResult?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        guard let imageCell = cell as? ImageCell else {
            assertionFailure("Didn't dequeue an ImageCell... somehow...")
            return cell
        }
        
        guard let asset = PhotoModel.shared.allPhotosFetchResult?.object(at: indexPath.row) else {
            return imageCell
        }
        
        imageCell.assetIdentifier = asset.localIdentifier
        cachingManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: {
            image, _ in
            
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            if imageCell.assetIdentifier == asset.localIdentifier {
                imageCell.imageView.image = image
            }
        })
    
        return imageCell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
}
