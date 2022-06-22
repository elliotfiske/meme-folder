//
//  RecentPhotosCollectionViewController.swift
//  memefolder
//
//  Created by Elliot Fiske on 2/14/21.
//  Copyright © 2021 Meme Folder. All rights reserved.
//

import UIKit
import Photos

import RxSwift
import RxCocoa

import YoutubeDL

private let reuseIdentifier = "Cell"

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
    
    
    fileprivate var allPhotosFetchResult: PHFetchResult<PHAsset>?
    fileprivate let changeObserver = PhotoLibraryChangeObserver()
    fileprivate let cachingManager = PHCachingImageManager()
    
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var thumbnailSize = CGSize.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [
            NSSortDescriptor(
                key: "creationDate",
                ascending: false)
        ]
        
        allPhotosOptions.fetchLimit = 100
        allPhotosOptions.includeAssetSourceTypes = [.typeCloudShared, .typeUserLibrary, .typeiTunesSynced]
        
        allPhotosFetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        
        // Register cell classes
        self.collectionView.register(UINib(nibName: "ImageCell", bundle: .main), forCellWithReuseIdentifier: reuseIdentifier)
        
        let itemWidth = view.bounds.width / 4
        collectionViewLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        changeObserver.rx.photoLibraryDidChange
            .observe(on: MainScheduler.instance)
            .bind(onNext: {
                [weak self] change in
                self?.handleChange(change)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func handleChange(_ change: PHChange) {
        guard let fetchResult = allPhotosFetchResult,
              let changes = change.changeDetails(for: fetchResult)
            else { return }
        
        allPhotosFetchResult = changes.fetchResultAfterChanges
        
        collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let scale = UIScreen.main.scale
        let cellSize = collectionViewLayout.itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotosFetchResult?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        guard let imageCell = cell as? ImageCell else {
            assertionFailure("Didn't dequeue an ImageCell... somehow...")
            return cell
        }
        
        guard let asset = allPhotosFetchResult?.object(at: indexPath.row) else {
            return imageCell
        }
        
        imageCell.assetIdentifier = asset.localIdentifier
        
        cachingManager.rx.requestImage(for: asset,
                                       targetSize: thumbnailSize,
                                       contentMode: .aspectFill,
                                       options: nil)
            .subscribe(onNext: {
                image in
                imageCell.imageView.image = image
            }, onError: {
                err in
                // TODO: Surface error to user, and also send it to Firebase.
                print("Some kind of error! \(err)")
            })
            .disposed(by: imageCell.reuseDisposeBag)
    
        return imageCell
    }

    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let asset = allPhotosFetchResult?.object(at: indexPath.row) else {
            return
        }
        
        let photoController = PhotoViewController.loadFromNib()
        photoController.assetToDisplay = asset
        navigationController?.pushViewController(photoController, animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil, completion: {
            [weak self] context in
            
            guard let collectionView = self?.collectionView,
                  let layout = self?.collectionViewLayout else {
                return
            }
            
            collectionView.performBatchUpdates({
                let newWidth = size.width / 4
                
                layout.itemSize = CGSize.init(width: newWidth, height: newWidth)
                
                collectionView.setCollectionViewLayout(layout, animated: false)
            })
        })
    }
}
