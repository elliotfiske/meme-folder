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
        
        case downloadingMedia(CGFloat)       // Value is the download progress 0 -> 1.0
        case downloadedMedia
        
        case savingMediaToCameraRoll
        case finished
    }
    
    private var state = MediaState.idle
    
    private func setState(newState: MediaState) {
        stateObserver?.stateDidChange(newState: newState)
    }
    
    public private(set) var thumbnailImage: UIImage?
    
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
        .then { data, _ -> Promise<(data: Data, response: PMKAlamofireDataResponse)> in
            self.thumbnailImage = UIImage(data: data)
            self.setState(newState: .downloadedThumbnail)

            return Alamofire.request(mediaURLToDownload!)
                .validate()
                .downloadProgress(closure: { progress in
                    self.setState(newState: .downloadingMedia(CGFloat(progress.fractionCompleted)))
                })
                .responseData()
        }
        .done { _, _ in
            self.setState(newState: .downloadedMedia)
        }
    }
}
