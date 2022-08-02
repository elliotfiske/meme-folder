//
//  PhotoLibraryChangeObserver.swift
//  ha1fAlbum
//
//  Created by はるふ on 2018/10/29.
//  Copyright © 2018年 はるふ. All rights reserved.
//

import Photos
import RxSwift
import RxCocoa

/// We need this class to hide PHPhotoLibraryChangeObserver methods.
private final class PhotoLibraryChangeObserverSink: NSObject {
    fileprivate let _publish = PublishRelay<PHChange>()
}

extension PhotoLibraryChangeObserverSink: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        _publish.accept(changeInstance)
    }
}

public final class PhotoLibraryChangeObserver: NSObject {
    fileprivate let _sink = PhotoLibraryChangeObserverSink()
    fileprivate let _photoLibrary: PHPhotoLibrary
    
    public init(photoLibrary: PHPhotoLibrary = PHPhotoLibrary.shared()) {
        _photoLibrary = photoLibrary
        super.init()
    }
    
    deinit {
        _photoLibrary.unregisterChangeObserver(_sink)
    }
}

extension Reactive where Base == PhotoLibraryChangeObserver {
    public var photoLibraryDidChange: Observable<PHChange> {
        return base._sink._publish
            .do(onSubscribed: { [weak base] in
                guard let base = base else {
                    return
                }
                base._photoLibrary.register(base._sink)
            }, onDispose: { [weak base] in
                guard let base = base else {
                    return
                }
                base._photoLibrary.unregisterChangeObserver(base._sink)
            })
    }
}

