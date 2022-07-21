//
//  AVVideoPlayerView.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 2/21/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import RxSwift
import RxRelay

import NSObject_Rx

@IBDesignable
class AVVideoPlayerView: UIView, NibLoadable {
    
    @IBOutlet weak var videoLoadingProgress: UIProgressView!
    
    public var loadingProgress = BehaviorRelay<Float>(value: 0)
    
    public let readyToPlay = PublishRelay<Bool>()
    
    public let currPlaybackTime = PublishRelay<CGFloat>()
    
    /// The currently loaded item's length in seconds
    public let itemLength = BehaviorRelay<CGFloat>(value: 0)
    
    public var itemToPlay: Binder<AVPlayerItem> {
        return Binder(playerToPlay) { [weak self] (player, newItem) in
            player.replaceCurrentItem(with: newItem)
            self?.readyToPlay.accept(false)
        }
    }
    
    public var requestedSeekTime = PublishRelay<CGFloat>()
    
    public var isPlaying = BehaviorRelay<Bool>(value: false)
    
    var player: AVPlayer = AVPlayer()
    weak var playerLayer: AVPlayerLayer?
    
    func stop() {
        player.replaceCurrentItem(with: nil)
    }
    
    func commonInit() {
        let strongPlayerLayer = AVPlayerLayer(player: self.player)
        self.playerLayer = strongPlayerLayer
        
        strongPlayerLayer.videoGravity = .resizeAspect
        self.layer.addSublayer(strongPlayerLayer)
        player.actionAtItemEnd = .none
        player.seek(to: CMTime.zero)
        
        rx.disposeBag.insert(
        loadingProgress.bind(to: self.videoLoadingProgress.rx.progress),
        
        self.player.rx.status
            .map { $0 == .readyToPlay }
            .bind(to: self.readyToPlay),
        
        // Auto-play the video the first time it loads
        self.readyToPlay
            .filter { $0 == true }
            .take(1)
            .bind(to: isPlaying),
        
        isPlaying
            .bind(to: player.rx.isPlaying),
        
        self.readyToPlay
            .filter { $0 == true }
            .map({ [weak self] _ in
                guard let playerItem = self?.player.currentItem else { return 0 }
                
                let lengthInSeconds = CGFloat(CMTimeGetSeconds(playerItem.asset.duration))
                return lengthInSeconds
            })
            .bind(to: self.itemLength),
        
        player.rx.periodicTimeObserver(interval: CMTime(value: 1, timescale: 10))
            .map { CGFloat(CMTimeGetSeconds($0)) }
            .do(onDispose: {
                print("disposed!")
            })
            .bind(to: currPlaybackTime),
        
        NotificationCenter.default.rx
            .notification(.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
            .subscribe(onNext: {
                notification in
                if let playerItem = notification.object as? AVPlayerItem {
                    playerItem.seek(to: CMTime.zero, completionHandler: nil)
                }
            }),
        
        self.requestedSeekTime
            .throttle(.milliseconds(20), scheduler: MainScheduler.instance)
            .flatMap({
                [weak self] (progress) -> Observable<Bool> in
                
                let secs = Double((self?.itemLength.value ?? 0.0) * progress)
                let time = CMTime(seconds: secs, preferredTimescale: 600)
                
                return Observable<Bool>.create {
                    observer in
                    self?.player.seek(to: time,
                                       toleranceBefore: CMTime.init(seconds: 0.1, preferredTimescale: 600),
                                      toleranceAfter: CMTime.init(seconds: 0.1, preferredTimescale: 600),
                                      completionHandler: observer.onNext)
                    return Disposables.create()
                }
            })
            .subscribe(onNext: {
                print("Did it seek properly? \($0)")
            }))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.playerLayer?.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
        commonInit()
    }
}
