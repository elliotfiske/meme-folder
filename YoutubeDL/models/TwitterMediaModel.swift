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

public protocol TwitterMediaModelObserver {
    func stateDidChange(newState: TwitterMediaModel.MediaState)
}

public class TwitterMediaModel {
    
    public var stateObserver: TwitterMediaModelObserver?
    
    public enum MediaState {
        case idle
        
        case downloadingThumbnail
        case downloadedThumbnail
        
        case downloadingMedia(Double)       // Value is the download progress 0 -> 1.0
        case downloadedMedia
        
        case savingMediaToCameraRoll
        case finished
    }
    
    private var state = MediaState.idle
    
    private func setState(newState: MediaState) {
        stateObserver?.stateDidChange(newState: newState)
    }
    
    public private(set) var thumbnailImage: UIImage?
    
    public func startDownloadingMedia(forTweetURL tweetURL: String) -> Promise<Int> {

        var mediaURLToDownload: String?
        
        return firstly {
            try TwitterAPI.sharedInstance.getMediaURLs(usingTweetURL: tweetURL)
        }
        .then { (thumbnailURL: String, mediaURL: String?) ->
            Promise<(data: Data, response: PMKAlamofireDataResponse)>  in
            
            mediaURLToDownload = mediaURL
            self.setState(newState: .downloadingThumbnail)
            
            return Alamofire.request(thumbnailURL)
                .validate()
                .responseData()
        }
        .map { data, _ in
            self.thumbnailImage = UIImage(data: data)
            self.setState(newState: .downloadedThumbnail)
            
            return 3
        }
    }
}
