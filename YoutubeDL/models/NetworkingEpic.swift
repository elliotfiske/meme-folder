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

public struct GetPokemonAbilityInfoByPokemonName: Action {
    public init(payload: String) { self.payload = payload }
    var payload: String
}

public struct GetPokemonAbilityInfoByPokemonName_Fulfilled: Action {
    var payload: String
}

public struct GetPokemonInfoByName: Action {
    var payload: String
}

public struct GetPokemonInfoByName_Fulfilled: Action {
    var payload: JSON
}

func forkEpic(
    epic: (Observable<Action>) -> Observable<Action>, action: Action
) -> Observable<Action> {
    let actions$ = Observable.just(action)
    return epic(actions$)
}

public let getPokemonInfoEpic: Epic<TwitterMediaGrabberState> = {
    action$, _ in

    return action$.compactMap {
        guard let pokemonName = ($0 as? GetPokemonInfoByName)?.payload else {
            return nil
        }
        return pokemonName
    }
    .flatMap { (pokemonName: String) -> Observable<Data> in
        let session = Session.default
        return session.rx.data(.get, "https://pokeapi.co/api/v2/pokemon/\(pokemonName)")
            .catchAndReturn("Error getting pokemon!".data(using: .utf8)!)
    }
    .map {
        data in
        let json =
            try (try? parseJSON(data: data))
            ?? (try parseJSON(data: "[\"foo\"]".data(using: .utf8)!))

        return GetPokemonInfoByName_Fulfilled(
            payload: json
        )
    }
}

public let getPokemonAbilityInfoByNameEpic: Epic<TwitterMediaGrabberState> = {
    action$, getState in

    return action$.compactMap {
        guard let pokemonName = ($0 as? GetPokemonAbilityInfoByPokemonName)?.payload else {
            return nil
        }
        return pokemonName
    }.flatMap {
        pokemonName -> Observable<GetPokemonInfoByName_Fulfilled> in
        return getPokemonInfoEpic(
            Observable.just(GetPokemonInfoByName(payload: pokemonName)), getState
        )
        .compactMap {
            guard let action = $0 as? GetPokemonInfoByName_Fulfilled else { return nil }
            return action
        }
    }
    .flatMap { action -> Observable<Action> in
        guard
            let pokemonAbilityUrl: String = action.payload["abilities"][0]["ability"]["url"].string
        else {
            return Observable.just(
                GetPokemonAbilityInfoByPokemonName_Fulfilled(
                    payload:
                        "Error, couldn't find a URL in the first pokemon info object. Found \(action.payload.rawString() ?? "nothing")"
                )
            )
        }

        return Session.default.rx.data(.get, pokemonAbilityUrl)
            .map {
                data in
                let json = try parseJSON(data: data)

                guard let abilityDescription = json["effect_entries"][0]["effect"].string else {
                    throw ElliotError(
                        localizedMessage: "Unexpected JSON: \(json.rawString() ?? "ahh")")
                }

                return GetPokemonAbilityInfoByPokemonName_Fulfilled(payload: abilityDescription)
            }
    }
    .observe(on: MainScheduler.instance)
}

public let simple_networkingEpic: Epic<TwitterMediaGrabberState> = {
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
                    return DownloadMediaProgress(
                        localMediaURL: APIState.pending, progress: $0.progress)
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

public let networkingEpic = combineEpics(epics: [
    simple_networkingEpic, getPokemonInfoEpic, getPokemonAbilityInfoByNameEpic,
])
