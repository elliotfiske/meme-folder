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
    
    private let disposeBag = DisposeBag()   // TODO: Extensionize me
    
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
    
    public let playButtonPressSink = PublishRelay<Void>()
    
    // True if the player is currently playing.
    // My idea is to let other classes see the OBSERVABLE side
    //      i.e. they can see when the play state changes
    //      but they shouldn't be able to directly change the state of the
    //      model. They can send in events via stuff like "playButtonPresses"
    //      which the model then uses to transform its own internal state.
    public let playerIsPlaying = BehaviorRelay<Bool>(value: false)
    
    private let state_internal = BehaviorRelay<MediaState>(value: .idle)
    public lazy var state = state_internal.asObservable()
    
    private func setState(newState: MediaState) {
        state_internal.accept(newState)
    }
    
    public private(set) var thumbnailImage: UIImage?
    
    /// Points to where the downloaded media is stored locally.
    public private(set) var localMediaURL: URL?
    
    init() {
        
        let readyToPlay = state.filter {
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
                // this TECHNICALLY works but I'm not happy about it.
                //      I think you could do something fancy with Scan or Reduce or something
                //      and not have to use `value` at all, if you're clever about it.
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
        documentsURL.appendPathComponent("familyguy.mp4")

        return (documentsURL, [.removePreviousFile])
    }
    
    public func startDownloadingMedia(forTweetURL tweetURL: String) {

        var mediaURLToDownload: String?
        
        firstly {
            try TwitterAPI.sharedInstance.getMediaURLs(usingTweetURL: tweetURL)
        }
        .then { mediaResults ->
            Promise<(data: Data, response: PMKAlamofireDataResponse)> in
            
            self.setState(newState: .downloadingThumbnail)
            
            switch (mediaResults) {
            case .videos(let thumbnail, let variants):
                mediaURLToDownload = variants[0]
                return Alamofire.request(thumbnail)
                    .validate()
                    .responseData()
            case .images(let urls):
                return Alamofire.request(urls[0])
                    .validate()
                    .responseData()
            }
        }
        .then { data, _ -> Promise<Void> in
            self.thumbnailImage = UIImage(data: data)
            self.setState(newState: .downloadedThumbnail)

            // TODO: pull this out to an extension. It should look like:
            //      Alamofire.download(.promise, mediaURLToDownload!, to: self.destination)
            //          ... and you don't have to use the 'Promise<Void> seal' stuff.
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
        // TODO: Handle errors down here. Should use 'recover' and then also return,
        //          so the view controller can handle the errors how it sees fit.
    }
}
