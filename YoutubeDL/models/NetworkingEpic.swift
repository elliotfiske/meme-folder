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
    
    let twitter: Observable<Action> = action$.compactMap {
        if case let TwitterAPIAction.getMediaFromTweet(url) = $0 {
            return url
        }
        return nil
    }
    .flatMapLatest {
        return try TwitterAPI.sharedInstance.getMediaURLsRx(for: $0)
            .map {
                mediaUrls in
                TwitterAPIAction.mediaURLs(APIState.fulfilled(mediaUrls))
            }
            .catch {
                return Observable.just(TwitterAPIAction.mediaURLs(APIState.error($0)))
            }
    }
    
    let pokemon: Observable<Action> = action$.compactMap {
        action -> String? in
        if case let NumbersAPIAction.getNumberFact(num) = action {
            return "https://pokeapi.co/api/v2/type/\(num)"
        }
        return nil
    }.flatMap {
        url -> Observable<Data> in
        
        let request = URLRequest(url: URL(string: url)!)
        
        return URLSession.shared.rx.data(request: request)
    }.map {
        let json = try parseJSON(data: $0)
        return NumbersAPIAction.numberFact(.fulfilled(json["name"].stringValue))
    }.catch {
        return Observable.just(NumbersAPIAction.numberFact(.error($0)))
    }
    
    return Observable<Action>.merge(twitter, pokemon)
}
