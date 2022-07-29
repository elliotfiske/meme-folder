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

public let networkingEpic: Epic<TwitterMediaGrabberState> = {
    action$, getState in
    
    let getMediaUrl: Observable<Action> = action$.compactMap {
        if case let TwitterAPIAction.getMediaFromTweet(url) = $0 {
            return url
        }
        return nil
    }
    .flatMapLatest {
        return try TwitterAPI.sharedInstance.getMediaURLsRx(for: $0)
            .map {
                mediaUrls in
                TwitterAPIAction.mediaURLs(.fulfilled(mediaUrls))
            }
            .catch {
                return Observable.just(TwitterAPIAction.mediaURLs(APIState.error($0)))
            }
    }
    
    let getMediaSizes: Observable<Action> = action$.compactMap {
        if case let TwitterAPIAction.mediaURLs(state) = $0 {
            if case let .fulfilled(mediaUrls) = state {
                if case let .videos(thumbnail: _, urls: vidUrls) = mediaUrls {
                    return vidUrls
                }
            }
        }
        return nil
    }
    .flatMapLatest {
        (urls: [String]) in
        return Observable.merge(
            try urls.map {
                url in
                try TwitterAPI.sharedInstance.getMediaSize(for: url).map {
                    return TwitterAPIAction.gotVideoSize(url: url, size: $0)
                }
            }
        )
    }
    
    let downloadMedia: Observable<Action> = action$.compactMap {
        if case let TwitterAPIAction.downloadMedia(url) = $0 {
            return url
        }
        return nil
    }
    .flatMapLatest {
        return TwitterAPI.sharedInstance.downloadMedia(atUrl: $0)
            .map {
                if let url = $0.localUrl {
                    return TwitterAPIAction.downloadedMediaProgress(.fulfilled(url), 1.0)
                } else {
                    return TwitterAPIAction.downloadedMediaProgress(APIState.pending, $0.progress)
                }
            }
    }
    
    
    return Observable<Action>.merge(getMediaUrl, getMediaSizes, downloadMedia)
}
