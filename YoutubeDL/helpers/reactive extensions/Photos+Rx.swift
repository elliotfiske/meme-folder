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
    public func requestImage(
        for asset: PHAsset,
        targetSize: CGSize,
        contentMode: PHImageContentMode,
        options: PHImageRequestOptions?
    ) -> Observable<UIImage> {
        return Observable.create {
            [weak base] subscriber in

            let requestId = base?.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: contentMode,
                options: options
            ) {
                image, infoDict in
                guard let imageUnwrapped = image else {
                    let error = infoDict?[PHImageErrorKey] as? NSError

                    subscriber.onError(
                        ElliotError(
                            localizedMessage: "Couldn't fetch photo.",
                            developerMessage:
                                "Error retrieving photo. Description: \(String(describing: error?.localizedDescription)). Full error: \(String(describing: error))",
                            category: .iosError))
                    return
                }

                subscriber.onNext(imageUnwrapped)
            }

            return Disposables.create {
                guard let requestId = requestId else { return }
                base?.cancelImageRequest(requestId)
            }
        }
    }
}

//
//  PHPhotoLibrary+Rx.swift
//  RxPhotos
//
//  Created by Anton Romanov on 01/04/2018.
//  Copyright © 2018 Istered. All rights reserved.
//
extension Reactive where Base: PHPhotoLibrary {
    public static func requestAuthorization() -> Single<PHAuthorizationStatus> {
        return Single.create { single in
            PHPhotoLibrary.requestAuthorization { status in
                single(.success(status))
            }

            return Disposables.create()
        }
    }

    public func rxPerformChanges(_ changeBlock: @escaping () -> Void) -> Single<Bool> {
        return Single.create { [weak base] single in
            base?.performChanges(changeBlock) { result, error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(result))
                }
            }

            return Disposables.create()
        }
    }
}
