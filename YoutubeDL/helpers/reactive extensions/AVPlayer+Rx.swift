//
//  AVPlayer+Rx.swift
//  RxAVPlayer
//
//  Created by Patrick Mick on 3/30/16.
//  Copyright © 2016 YayNext. All rights reserved.
//

import Foundation
import AVFoundation
import RxSwift
import RxCocoa

extension Reactive where Base: AVPlayer {
    
    /// Bindable sink for `play()`, `pause()` methods.
    public var isPlaying: Binder<Bool> {
        return Binder(self.base) { player, shouldPlay in
            if shouldPlay {
                player.play()
            } else {
                player.pause()
            }
        }
    }
    
    public var rate: Observable<Float> {
        return self.observe(Float.self, #keyPath(AVPlayer.rate))
            .map { $0 ?? 0 }
    }

    public var currentItem: Observable<AVPlayerItem?> {
        return observe(AVPlayerItem.self, #keyPath(AVPlayer.currentItem))
    }
    
    public var status: Observable<AVPlayer.Status> {
        return self.observe(AVPlayer.Status.self, #keyPath(AVPlayer.status))
            .map { $0 ?? .unknown }
    }
    
    public var error: Observable<NSError?> {
        return self.observe(NSError.self, #keyPath(AVPlayer.error))
    }
    
    @available(iOS 10.0, tvOS 10.0, *)
    public var reasonForWaitingToPlay: Observable<AVPlayer.WaitingReason?> {
        return self.observe(AVPlayer.WaitingReason.self, #keyPath(AVPlayer.reasonForWaitingToPlay))
    }
    
    @available(iOS 10.0, tvOS 10.0, *)
    public var timeControlStatus: Observable<AVPlayer.TimeControlStatus> {
        return self.observe(AVPlayer.TimeControlStatus.self, #keyPath(AVPlayer.timeControlStatus))
            .map { $0 ?? .waitingToPlayAtSpecifiedRate }
    }
    
    public func periodicTimeObserver(interval: CMTime) -> Observable<CMTime> {
        return Observable.create { [weak base] observer in
            let t = base?.addPeriodicTimeObserver(forInterval: interval, queue: nil) { time in
                observer.onNext(time)
            }
            
            return Disposables.create {
                if let t = t {
                    base?.removeTimeObserver(t)
                }
            }
        }
    }
    
    public func boundaryTimeObserver(times: [CMTime]) -> Observable<Void> {
        return Observable.create { [weak base] observer in
            let timeValues = times.map() { NSValue(time: $0) }
            let t = base?.addBoundaryTimeObserver(forTimes: timeValues, queue: nil) {
                observer.onNext(())
            }
            
            return Disposables.create {
                if let t = t {   
                    self.base.removeTimeObserver(t)
                }
            }
        }
    }
}
