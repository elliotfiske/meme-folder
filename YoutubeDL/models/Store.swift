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

public struct TwitterMediaGrabberState {
    /// Points to where the downloaded media is stored locally.
    var localMediaURL: APIState<URL> = .idle
    var downloadedMediaProgress: Double = 0
    
    var thumbnailURL: URL?
    
    var tweetURL: String?
    
    var twitterGuestToken: APIState<String> = .idle
    
    var mediaResultURL: APIState<TwitterAPI.MediaResultURLs> = .idle
    
    public var coolPokemonFact: APIState<String> = .idle
}

public protocol APIStateLike {
    associatedtype Result
    
    func isIdle() -> Bool
    func getError() -> Error?
    func getResult() -> Result?
}

public enum APIState<T>: APIStateLike {
    public typealias Result = T
    case idle, pending, progress(Float)
    case error(Error)
    case fulfilled(Result)
    
    public func isIdle() -> Bool {
        if case .idle = self {
            return true
        }
        return false
    }
    
    public func getError() -> Error? {
        if case let .error(err) = self {
            return err
        }
        return nil
    }
    
    public func getResult() -> T? {
        if case let .fulfilled(result) = self {
            return result
        }
        return nil
    }
    
    public func getProgress() -> Float? {
        if case let .progress(poggers) = self {
            return poggers
        }
        return nil
    }
}

public enum NumbersAPIAction: Action {
    case getNumberFact(Int)
    case numberFact(APIState<String>)
}

public enum TwitterAPIAction: Action {
    case getMediaFromTweet(String)
    case mediaURLs(APIState<TwitterAPI.MediaResultURLs>)
    
    case downloadMedia(url: String)
    case downloadedMediaProgress(APIState<URL>, Double)
    
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
    case TwitterAPIAction.downloadedMediaProgress(let result, let progress):
        state.localMediaURL = result
        state.downloadedMediaProgress = progress
        
    default: break
    }
    
    return state
}

let epicMiddleware = EpicMiddleware<TwitterMediaGrabberState>(epic: networkingEpic).createMiddleware()

public let store = Store(reducer: appReducer, state: nil, middleware: [epicMiddleware])


