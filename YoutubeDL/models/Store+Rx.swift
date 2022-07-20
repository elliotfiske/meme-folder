//
//  Store+Rx.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 7/4/22.
//  Copyright © 2022 Meme Folder. All rights reserved.
//

import Foundation
import ReSwift
import RxSwift

// Simple wrapper that allows us to turn the Subscriber delegate into a stream
class ObserverSub<State, ObservedValueType>: StoreSubscriber {
    typealias StoreSubscriberStateType = State
    
    public var observer: AnyObserver<ObservedValueType>
    public var keyPath: KeyPath<State, ObservedValueType>
    
    init(observer: AnyObserver<ObservedValueType>, keyPath: KeyPath<State, ObservedValueType>) {
        self.observer = observer
        self.keyPath = keyPath
    }
    
    func newState(state: State) {
        observer.onNext(state[keyPath: keyPath])
    }
}

/**
 * Extension that lets us create Observable streams from the Store and a given key path
 */
extension Store {
    open func observableFromPath<Result>(keyPath: KeyPath<State, Result>) -> Observable<Result> {
        return Observable<Result>.create {
            [self] observer in
            
            let subscriber = ObserverSub(observer: observer, keyPath: keyPath)
            
            self.subscribe(subscriber)
            
            return Disposables.create {
                self.unsubscribe(subscriber)
            }
        }
    }
}

extension ObservableConvertibleType where Element: APIStateLike {
    public typealias Result = Element.Result
    
    public func apiError() -> Observable<Error> {
        return self.asObservable().compactMap {
                return $0.getError()
            }
    }
    
    // True if the API request is currently running
    public func activity() -> Observable<Bool> {
        return self.asObservable().compactMap {
            // TODO: Implement this
            _ in
            return true
        }
    }
    
    // Gotta be a type-smarter way to do this yo. I can't get it to have a generic around the APIState requirement.
    public func apiResult() -> Observable<Result> {
        return self.asObservable().compactMap {
            $0.getResult()
        }
    }
}
