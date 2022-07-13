//
//  Store.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 7/3/22.
//  Copyright © 2022 Meme Folder. All rights reserved.
//

import Foundation
import ReSwift
import RxSwift

import PromiseKit
import PMKAlamofire

public struct TwitterMediaGrabberState {
    /// Points to where the downloaded media is stored locally.
    var localMediaURL: URL?
    var thumbnailURL: URL?
    
    var tweetURL: String?
    
    var twitterGuestToken: APIState<String> = .idle
    
    var mediaResultURL: APIState<TwitterAPI.MediaResultURLs> = .idle
    
    public var coolPokemonFact: APIState<String> = .idle
}

public enum APIState<Result> {
    case idle, pending
    case error(Error)
    case fulfilled(Result)
}

public enum NumbersAPIAction: Action {
    case getNumberFact(Int)
    case numberFact(APIState<String>)
}

public enum TwitterAPIAction: Action {
    case getMediaFromTweet(String)
    case mediaURLs(APIState<TwitterAPI.MediaResultURLs>)
    
    case refreshToken
    case setToken(String)
}

func appReducer(action: Action, state: TwitterMediaGrabberState?) -> TwitterMediaGrabberState {
    var state = state ?? TwitterMediaGrabberState()
    
    switch action {
    case NumbersAPIAction.numberFact(let result):
        state.coolPokemonFact = result
    case TwitterAPIAction.getMediaFromTweet(let url):
        state.tweetURL = url
    case TwitterAPIAction.mediaURLs(let result):
        state.mediaResultURL = result
        
    default: break
    }
    
    return state
}

let epicMiddleware = EpicMiddleware<TwitterMediaGrabberState>(epic: networkingEpic).createMiddleware()

public let store = Store(reducer: appReducer, state: nil, middleware: [epicMiddleware])


