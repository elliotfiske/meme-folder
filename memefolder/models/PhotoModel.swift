//
//  PhotoModel.swift
//  memefolder
//
//  Created by Elliot Fiske on 2/4/21.
//  Copyright © 2021 Meme Folder. All rights reserved.
//

import Foundation
import Photos
import UIKit

import RxSwift

public class PhotoModel: NSObject, PHPhotoLibraryChangeObserver {
    static let shared = PhotoModel()
    
    public class PhotoRetrievalError: Error {
        var message: String
        
        init(message: String) {
            self.message = message
        }
    }
    
    public var allPhotosFetchResult: PHFetchResult<PHAsset>?
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        print("Oh yeah we do be here now \(changeInstance)")
//        print("but what about me??? \(self.allPhotosFetchResult!)")
        
//        if let changeDetails = changeInstance.changeDetails(for: allPhotosFetchResult) {
//            print("aight")
//        }
    }
    
    func numPhotos() -> Int {
        return allPhotosFetchResult?.count ?? 0
    }
    
    func asset(at index: Int) -> PHAsset? {
        return allPhotosFetchResult?[index]
    }
    
    public let cacher = PHCachingImageManager()
    
    func getRecentPhotos() -> Observable<UIImage> {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [
          NSSortDescriptor(
            key: "creationDate",
            ascending: false)
        ]
//        allPhotosOptions.fetchLimit = 10
        allPhotosOptions.includeAssetSourceTypes = [.typeCloudShared, .typeUserLibrary, .typeiTunesSynced]
        
        let auth = PHPhotoLibrary.authorizationStatus()
        print(auth)
        
        return Observable.create {
            observer in
            
            self.allPhotosFetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
            
//            cacher.startCachingImages(for: self.allPhotosFetchResult!, targetSize: CGSize.init(width: 200, height: 200), contentMode: .aspectFill, options: nil)
            
            PHPhotoLibrary.shared().register(self)
            
            var requestId: PHImageRequestID?
            let manager = PHImageManager.default()
            
            
            if let lastAsset: PHAsset = self.allPhotosFetchResult?.lastObject {
                let imageRequestOptions = PHImageRequestOptions()
                imageRequestOptions.deliveryMode = .fastFormat
                
                requestId = manager.requestImage(for: lastAsset,
                                                 targetSize: CGSize.init(width: 200, height: 200),
                                                 contentMode: .aspectFit,
                                                 options: imageRequestOptions,
                                                 resultHandler: {
                                                    image, dict in
                                                    if let imageUnwrapped = image {
                                                        observer.onNext(imageUnwrapped)
                                                    } else {
                                                        if let errorMessage = dict?[PHImageResultIsDegradedKey] as? String {
                                                            observer.onError(PhotoRetrievalError(message: errorMessage))
                                                        } else {
                                                            observer.onError(PhotoRetrievalError(message: "Couldn't retrieve image..."))
                                                        }
                                                    }
                                                 })
            }
            
            return Disposables.create {
                if let requestIdUnwrapped = requestId {
                    manager.cancelImageRequest(requestIdUnwrapped)
                }
            }
        }
    }
}
