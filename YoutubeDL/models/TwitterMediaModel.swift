//
//  TwitterMediaModel.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 1/10/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import Foundation
import UIKit
import Photos

import RxRelay
import RxSwift

import NSObject_Rx

public protocol TwitterMediaModelObserver : AnyObject {
    func stateDidChange(newState: TwitterMediaModel.MediaState)
}

public class TwitterMediaModel: HasDisposeBag {
    
    public weak var stateObserver: TwitterMediaModelObserver?
    
    public enum MediaState {
        case idle
        
        case downloadingThumbnail
        case downloadedThumbnail
        
        case downloadingMedia(Float)       // Value is the download progress 0 -> 1.0
        case downloadedMedia
        
        case savingMediaToCameraRoll
        case finished
        
        case error(Error)
    }
    
    public let playButtonPressSink = PublishRelay<Void>()
    
    // True if the player is currently playing.
    // My idea is to let other classes see the OBSERVABLE side
    //      i.e. they can see when the play state changes
    //      but they shouldn't be able to directly change the state of the
    //      model. They can send in events via stuff like "playButtonPresses"
    //      which the model then uses to transform its own internal state.
    private let state_internal = BehaviorRelay<MediaState>(value: .idle)
    public lazy var state = state_internal.asObservable()
    
    
    private func setState(newState: MediaState) {
        state_internal.accept(newState)
    }
    
    public private(set) var thumbnailImage: UIImage?
    
    /// Points to where the downloaded media is stored locally.
    public private(set) var localMediaURL: URL?
    
    //
    // "destination" is a closure that takes the 'remote url' where we got
    //      the mp4 from, and returns a local URL of where to stick it, and
    //      how to stick it.
    //
    // TODO: This seems to be ending up with something like "CFDownload_woeifj.mp4"
    //          need to figure out how to get it to the original filename, maybe.
    //
    
    public func saveMediaToCameraRoll() {
        // TODO: Maybe rxify this stuff instead?
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .video, fileURL: self.localMediaURL!, options: nil)
        }) { (result, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.setState(newState: .error(error))
                } else {
                    self.setState(newState: .finished)
                }
            }
        }
    }
}
