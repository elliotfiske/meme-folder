//
//  TwitterMediaModel.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 1/10/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import Foundation
import UIKit

import PMKAlamofire
import PromiseKit

import RxRelay
import RxSwift

public protocol TwitterMediaModelObserver : class {
    func stateDidChange(newState: TwitterMediaModel.MediaState)
}

public class TwitterMediaModel {
    
    public weak var stateObserver: TwitterMediaModelObserver?
    
    public enum MediaState {
        case idle
        
        case downloadingThumbnail
        case downloadedThumbnail
        
        case downloadingMedia(Float)       // Value is the download progress 0 -> 1.0
        case downloadedMedia
        
        case savingMediaToCameraRoll
        case finished
    }
    
    /** Hacky, plz fix me */
        public let playButtonPressSink = PublishRelay<Void>()
        
        private let disposeBag = DisposeBag()   // TODO: Extensionize me
        
        // True if the player is currently playing.
        private let playerIsPlaying = BehaviorRelay<Bool>(value: false)
        public lazy var playerPlaying = playerIsPlaying.asObservable()
        
        private var state = MediaState.idle
        
        // this sucks hack
        private let stateObservable = BehaviorRelay<MediaState>(value: .idle)
        
        private func setState(newState: MediaState) {
            stateObserver?.stateDidChange(newState: newState)
            stateObservable.accept(newState)
        }
    /** END Hacky, plz fix me */
    
    public private(set) var thumbnailImage: UIImage?
    public private(set) var localMediaURL: URL?
    
    init() {
        let readyToPlay = stateObservable.filter {
            if case .downloadedMedia = $0 {
                return true
            }
            return false
        }
        .map { _ in Void() }
        
        Observable
            .combineLatest(playButtonPressSink, readyToPlay)
            .subscribe(onNext: {
                _ in
                // this TECHNICALLY works but I'm not happy about it
                self.playerIsPlaying.accept(!self.playerIsPlaying.value)
            })
            .disposed(by:disposeBag)
    }
    
    //
    // "destination" is a closure that takes the 'remote url' where we got
    //      the mp4 from, and returns a local URL of where to stick it, and
    //      how to stick it.
    //
    // TODO: This seems to be ending up with something like "CFDownload_woeifj.mp4"
    //          need to figure out how to get it to the original filename, maybe.
    //
    let destination: DownloadRequest.DownloadFileDestination = { url, _ in
        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        documentsURL.appendPathComponent(url.deletingPathExtension().lastPathComponent + ".mp4")

        return (documentsURL, [.removePreviousFile])
    }
    
    public func startDownloadingMedia(forTweetURL tweetURL: String) {

        var mediaURLToDownload: String?
        
        firstly {
            try TwitterAPI.sharedInstance.getMediaURLs(usingTweetURL: tweetURL)
        }
        .then { (thumbnailURL: String, mediaURL: String?) ->
            Promise<(data: Data, response: PMKAlamofireDataResponse)> in
            
            mediaURLToDownload = mediaURL
            self.setState(newState: .downloadingThumbnail)
            
            return Alamofire.request(thumbnailURL)
                .validate()
                .responseData()
        }
        .then { data, _ -> Promise<Void> in
            self.thumbnailImage = UIImage(data: data)
            self.setState(newState: .downloadedThumbnail)

            // TODO: pull this out to an extension, maybe
            return Promise<Void>() { seal in
                Alamofire.download(mediaURLToDownload!, to: self.destination)
                    .validate()
                    .downloadProgress(closure: { progress in
                        self.setState(newState: .downloadingMedia(Float(progress.fractionCompleted)))
                    })
                    .response { response in
                        if response.destinationURL != nil {
                            self.localMediaURL = response.destinationURL!
                            seal.fulfill(())
                        }
                    }
            }
        }
        .done { _ in
            self.setState(newState: .downloadedMedia)
        }
    }
}
