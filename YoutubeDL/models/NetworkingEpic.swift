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
import RxAlamofire
import Alamofire
import SwiftyJSON

let previewTweetEpic: Epic<TwitterMediaGrabberState> = {
    action$, getState in

    return action$.compactMap {
        guard let tweet = ($0 as? PreviewTweet)?.payload else {
            return nil
        }

        return tweet
    }
    .flatMap { tweet in
        return mediaUrlsForTweetEpic(
            Observable.just(GetMediaURLsFromTweet(payload: tweet)), getState
        )
        .flatMap {
            (action) -> Observable<Action> in

            guard let action = action as? FetchedMediaURLsFromTweet,
                case let .fulfilled(media) = action.urls
            else {
                return Observable.just(action)
            }

            let downloadMediaAction = DownloadMedia(url: media.videos!.last!.url)

            return Observable.concat(
                Observable.just(action),
                downloadMediaEpic(Observable.just(downloadMediaAction), getState))
        }
    }
}

let mediaUrlsForTweetEpic: Epic<TwitterMediaGrabberState> = {
    action$, _ in

    action$.compactMap {
        guard let url = ($0 as? GetMediaURLsFromTweet)?.payload else {
            return nil
        }

        return url
    }
    .flatMapLatest {
        return try TwitterAPI.sharedInstance.getMediaURLsRx(for: $0)
            // TODO: I could abstract this to a nice function
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
}

let downloadMediaEpic: Epic<TwitterMediaGrabberState> = {
    action$, _ in

    action$.compactMap {
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
                    return DownloadMediaProgress(
                        localMediaURL: APIState.pending, progress: $0.progress)
                }
            }
    }
}

let saveMediaToCameraRollEpic: Epic<TwitterMediaGrabberState> = {
    action$, getState in

    var badThing = 0
    
    return action$.compactMap {
        guard let action = $0 as? SaveToCameraRoll else {
            return nil
        }
        return action
    }
    .flatMap {
        (action: SaveToCameraRoll) in
        return PHPhotoLibrary.rx.requestAuthorization()
            .asObservable()
            .map {
                result -> SaveToCameraRoll in
                switch result {
                case .authorized, .limited:
                    return action
                default:
                    badThing = action.payload
                    throw ElliotError(localizedMessage: "Please allow Photo Library Access!", category: .photoLibraryAccessDenied)
                }
            }
    }
    .flatMap {
        (action: SaveToCameraRoll) -> Observable<SaveToCameraRoll> in
        // Wait until the media is downloaded, or go ahead right away if it already was
        if case .fulfilled = getState()!.localMediaURL {
            return Observable.just(action)
        }
        
        return action$.compactMap {
            guard let finishedDownloadAction = $0 as? DownloadMediaProgress else {
                return nil
            }
            
            guard case .fulfilled = finishedDownloadAction.localMediaURL else {
                return nil
            }
            
            return action
        }
        .take(1)
    }
    // todo: compactMap that checks if the current downloaded file is actually the one the user wants
    //      until then, you always get the most HD file :P
    .flatMap {
        (action: SaveToCameraRoll) -> Observable<Action> in

        guard case let .fulfilled(url) = getState()!.localMediaURL else {
            throw ElliotError(localizedMessage: "Unknown error occured!",
                              developerMessage: "Shouldn't get here... we should have waited until download finish to save to camera roll.")
        }

        let result: Observable<Action> = PHPhotoLibrary.shared().rx.rxPerformChanges({
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .video, fileURL: url, options: nil)
        })
        .asObservable()
        .map {
            _ in
            return SavedToCameraRoll(success: .fulfilled(true), index: action.payload)
        }
        .catch { error in
            return Observable.just(SavedToCameraRoll(success: .error(error), index: action.payload))
        }
        // This might mess stuff up. Be afraid.
        return result.startWith(SavedToCameraRoll(success: .pending, index: action.payload))
    }
    .catch {
        err in
        return Observable.just(SavedToCameraRoll(success: .error(err), index: badThing))
    }
}

public let getVideoFilesizesEpic: Epic<TwitterMediaGrabberState> = {
    action$, getState in
    return action$.compactMap {
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
}

public let networkingEpic = combineEpics(epics: [
    getVideoFilesizesEpic,
    previewTweetEpic,
    downloadMediaEpic,
    mediaUrlsForTweetEpic,
    saveMediaToCameraRollEpic,
])
