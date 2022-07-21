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
    
    
    return Observable<Action>.merge(getMediaUrl, downloadMedia)
}
