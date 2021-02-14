//
//  RecentImageCollectionMediatingView.swift
//  memefolder
//
//  Created by Elliot Fiske on 2/9/21.
//  Copyright © 2021 Meme Folder. All rights reserved.
//

import UIKit
import Photos

import YoutubeDL

import NSObject_Rx

@IBDesignable
class RecentImageCollectionMediatingView: UIView, NibLoadable, UICollectionViewDataSource, UICollectionViewDelegate, PHPhotoLibraryChangeObserver {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
        commonInit()
    }
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
//        print("Oh yeah we do be here now \(changeInstance)")
//        print("but what about me??? \(self.fetchResult!)")
        
        self.collectionView.reloadData()
//        if let changeDetails = changeInstance.changeDetails(for: fetchResult) {
//            print("aight")
//        }
    }
    
    var sillyImage: UIImage?
    func commonInit() {
        PhotoModel.shared.getRecentPhotos()
            .subscribe(onNext: {
                [weak self] image in
                self?.sillyImage = image
                self?.collectionView.reloadData()
            }, onError: {
                error in
                print("huh? \(error)")
            }).disposed(by: rx.disposeBag)
        
        collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "image_cell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PhotoModel.shared.numPhotos()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image_cell", for: indexPath)
        
        if let ass = PhotoModel.shared.asset(at: indexPath.row) {
            PHImageManager.default().requestImage(for: ass, targetSize: CGSize.init(width: 200, height: 200), contentMode: .aspectFill, options: nil, resultHandler: {
                image, dict in
                if let imageUnwrapped = image,
                   let imageCell = cell as? ImageCell {
                    imageCell.imageView.image = imageUnwrapped
                }
            })
        }
        
        return cell
    }
    
    
    @IBOutlet var collectionView: UICollectionView!
    
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
