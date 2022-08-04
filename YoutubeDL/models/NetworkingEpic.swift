//
//  NetworkingEpic.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 7/10/22.
//  Copyright © 2022 Meme Folder. All rights reserved.
//

import Foundation
import RxSwift
import ReSwift
import Photos



public let networkingEpic: Epic<TwitterMediaGrabberState> = {
    action$, getState in
    
    let getMediaUrl: Observable<Action> = action$.compactMap {
        guard let url = ($0 as? GetMediaURLsFromTweet)?.payload else {
            return nil
        }
        
        return url
    }
        .flatMapLatest {
            return try TwitterAPI.sharedInstance.getMediaURLsRx(for: $0)
                .map {
                    mediaUrls in
                    return .fulfilled(mediaUrls)
                }
                .catch {
                    return Observable.just(.error($0))
                }
                .map {
                    return FetchedMediaURLsFromTweet(urls: $0)
                }
        }
    
    let getMediaSizes: Observable<Action> = action$.compactMap {
        guard case let .fulfilled(media) = ($0 as? FetchedMediaURLsFromTweet)?.urls else {
            return nil
        }
        
        guard let videos = media.videos else {
            return nil
        }
        
        return videos
    }
    .flatMapLatest {
        (videos: [TwitterAPI.MediaResultURLs_struct.Video]) in
        return Observable.merge(
            try videos.map {
                video in
                try TwitterAPI.sharedInstance.getMediaSize(for: video.url).map {
                    return FetchedVideoVariantFilesize(url: video.url, size: $0)
                }
            }
        )
    }
    
    let downloadMedia: Observable<Action> = action$.compactMap {
        guard let url = ($0 as? DownloadMedia)?.url else {
            return nil
        }
        
        return url
    }
    .flatMapLatest {
        return TwitterAPI.sharedInstance.downloadMedia(atUrl: $0)
            .map {
                if let url = $0.localUrl {
                    return DownloadMediaProgress(localMediaURL: .fulfilled(url), progress: 1.0)
                } else {
                    return DownloadMediaProgress(localMediaURL: APIState.pending, progress: $0.progress)
                }
            }
    }
    
    let saveMedia: Observable<Action> = action$.compactMap {
        guard case let .fulfilled(url) = ($0 as? DownloadMediaProgress)?.localMediaURL else {
            return nil
        }
        return url
    }
    .flatMap {
        (url: URL) -> Single<Action> in
        
        return PHPhotoLibrary.shared().rx.rxPerformChanges({
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .video, fileURL: url, options: nil)
        })
        .map {
            result in
            return SavedToCameraRoll(success: true)
        }
        .catchAndReturn(
            SavedToCameraRoll(success: false)
        )
    }
    
    
    return Observable<Action>.merge(getMediaUrl, getMediaSizes, downloadMedia, saveMedia)
}
