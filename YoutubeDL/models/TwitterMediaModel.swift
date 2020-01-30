//
//  TwitterMediaModel.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 1/10/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit
import PMKAlamofire

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
    
    private var state = MediaState.idle
    
    private func setState(newState: MediaState) {
        stateObserver?.stateDidChange(newState: newState)
    }
    
    public private(set) var thumbnailImage: UIImage?
    public private(set) var localMediaURL: URL?
    
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
