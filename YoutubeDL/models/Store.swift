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
    
    var mediaResultURL: APIState<TwitterAPI.MediaResultURLs_struct> = .idle
    
    var sizeForUrl: [String:Int] = [:]
    
    var savedToCameraRoll: Bool = false
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

public protocol PayloadAction: Action {
    associatedtype PayloadType
    var payload: PayloadType { get set }
    
    init(payload: PayloadType)
}

public struct GetMediaURLsFromTweet: PayloadAction {
    public var payload: String
    
    public init(payload: String) {
        self.payload = payload
    }
}

public struct FetchedMediaURLsFromTweet: Action {
    let urls: APIState<TwitterAPI.MediaResultURLs_struct>
}

public struct DownloadMedia: Action {
    public init(url: String) {
        self.url = url
    }
    
    let url: String
}

public struct DownloadMediaProgress: Action {
    let localMediaURL: APIState<URL>
    let progress: Double
}

public struct FetchedVideoVariantFilesize: Action {
    let url: String
    let size: Int
}

public struct SavedToCameraRoll: Action {
    let success: Bool
}

func appReducer(action: Action, state: TwitterMediaGrabberState?) -> TwitterMediaGrabberState {
    var state = state ?? TwitterMediaGrabberState()
    
    switch action {
    case let action as FetchedMediaURLsFromTweet:
        state.mediaResultURL = action.urls
    case let action as DownloadMediaProgress:
        state.localMediaURL = action.localMediaURL
        state.downloadedMediaProgress = action.progress
    case let action as FetchedVideoVariantFilesize:
        state.sizeForUrl[action.url] = action.size
    case let action as SavedToCameraRoll:
        state.savedToCameraRoll = action.success

    default:
        break
    }
    
    return state
}

let epicMiddleware = EpicMiddleware<TwitterMediaGrabberState>(epic: networkingEpic).createMiddleware()

public let store = Store(reducer: appReducer, state: nil, middleware: [epicMiddleware])


