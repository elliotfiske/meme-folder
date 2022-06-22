//
//  Photos+Rx.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 3/18/21.
//  Copyright © 2021 Meme Folder. All rights reserved.
//

import Foundation
import Photos
import UIKit

import RxSwift
import RxCocoa

extension Reactive where Base: PHCachingImageManager {
    public func requestImage(for asset: PHAsset,
                             targetSize: CGSize,
                             contentMode: PHImageContentMode,
                             options: PHImageRequestOptions?) -> Observable<UIImage> {
        return Observable.create {
            subscriber in
            
            let requestId = self.base.requestImage(for: asset,
                                   targetSize: targetSize,
                                   contentMode: contentMode,
                                   options: options) {
                image, infoDict in
                guard let imageUnwrapped = image else {
                    let error = infoDict?[PHImageErrorKey] as? NSError
                    let message = error?.localizedDescription ?? "Unknown error occurred"
                    
                    subscriber.onError(PhotoRetrievalError(message: message))
                    return
                }
                
                subscriber.onNext(imageUnwrapped)
            }
            
            return Disposables.create {
                self.base.cancelImageRequest(requestId)
            }
        }
    }
}
