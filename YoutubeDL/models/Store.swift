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

/** The Weird Zone **/

public struct TwitterMediaGrabberState {
    /// Points to where the downloaded media is stored locally.
    var localMediaURL: URL?
    var thumbnailURL: URL?
    
    var tweetURL: URL?
    
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

func appReducer(action: Action, state: TwitterMediaGrabberState?) -> TwitterMediaGrabberState {
    var state = state ?? TwitterMediaGrabberState()
    
    switch action {
    case NumbersAPIAction.numberFact(let result):
        state.coolPokemonFact = result
    default: break
    }
    
    return state
}

let myEpic: Epic<TwitterMediaGrabberState> = {
    action$, getState in
    
    
    
    return action$.compactMap {
        action -> String? in
        if case let NumbersAPIAction.getNumberFact(num) = action {
            return "https://pokeapi.co/api/v2/type/\(num)"
        }
        return nil
    }.flatMap {
        url in
        
        return Observable.create {
            observer in
            
            observer.onNext(NumbersAPIAction.numberFact(.pending))
            
            firstly {
                return Alamofire
                    .request(url, method: .get)
                    .responseData()
            }
            .done { data, _ in
                let json = try parseJSON(data: data)
                observer.onNext(NumbersAPIAction.numberFact(.fulfilled(json["name"].stringValue)))
            }
            .catch {
                error in
                observer.onNext(NumbersAPIAction.numberFact(.error(error)))
            }
            
            return Disposables.create()
        }
    }
}

let epicMiddleware = EpicMiddleware<TwitterMediaGrabberState>(epic: myEpic).createMiddleware()

public let store = Store(reducer: appReducer, state: nil, middleware: [epicMiddleware])

