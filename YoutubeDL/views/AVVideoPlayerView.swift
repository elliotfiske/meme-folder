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
    public lazy var loadingProgress = self.videoLoadingProgress.rx.progress
    
    public let readyToPlay = PublishRelay<Bool>()
    
    public let currPlaybackTime = PublishRelay<CGFloat>()
    
    /// The currently loaded item's length in seconds
    public let itemLength = BehaviorRelay<CGFloat>(value: 0)
    
    public var itemToPlay: Binder<AVPlayerItem>? {
        guard let playerToPlay = self.player else {
            return nil
        }
        
        return Binder(playerToPlay) { [weak self] (player, newItem) in
            player.replaceCurrentItem(with: newItem)
            self?.readyToPlay.accept(false)
        }
    }
    
    public var requestedSeekTime = PublishRelay<CGFloat>()
    
    public var isPlaying = BehaviorRelay<Bool>(value: false)
    
    var player: AVPlayer? = AVPlayer()
    weak var playerLayer: AVPlayerLayer?
    
    deinit {
        print("Is this even getting called?")
    }
    
    func stop() {
        player?.replaceCurrentItem(with: nil)
        player = nil
    }
    
    func commonInit() {
        let strongPlayerLayer = AVPlayerLayer(player: self.player)
        self.playerLayer = strongPlayerLayer
        
        strongPlayerLayer.videoGravity = .resizeAspect
        self.layer.addSublayer(strongPlayerLayer)
        player?.actionAtItemEnd = .none
        player?.seek(to: CMTime.zero)
        
        self.player?.rx.status
            .map { $0 == .readyToPlay }
            .bind(to: self.readyToPlay)
            .disposed(by: rx.disposeBag)
        
        // Auto-play the video the first time it loads
        self.readyToPlay
            .filter { $0 == true }
            .take(1)
            .bind(to: isPlaying)
            .disposed(by: rx.disposeBag)
        
        isPlaying
            .bind(to: player!.rx.isPlaying)
            .disposed(by: rx.disposeBag)
        
        self.readyToPlay
            .filter { $0 == true }
            .map({ [weak self] _ in
                guard let playerItem = self?.player?.currentItem else { return 0 }
                
                let lengthInSeconds = CGFloat(CMTimeGetSeconds(playerItem.asset.duration))
                return lengthInSeconds
            })
            .bind(to: self.itemLength)
            .disposed(by: rx.disposeBag)
        
        player?.rx.periodicTimeObserver(interval: CMTime(value: 1, timescale: 10))
            .map { CGFloat(CMTimeGetSeconds($0)) }
            .do(onDispose: {
                print("disposed!")
            })
            .bind(to: currPlaybackTime)
            .disposed(by: rx.disposeBag)
        
        NotificationCenter.default.rx
            .notification(.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
            .subscribe(onNext: {
                notification in
                if let playerItem = notification.object as? AVPlayerItem {
                    playerItem.seek(to: CMTime.zero, completionHandler: nil)
                }
            })
            .disposed(by: rx.disposeBag)
        
        self.requestedSeekTime
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .flatMap({
                [weak self] (progress) -> Observable<Bool> in
                
                let secs = Double(self?.itemLength.value ?? 0.0 * progress)
                let time = CMTime(seconds: secs, preferredTimescale: 600)
                
                return Observable<Bool>.create {
                    observer in
                    self?.player?.seek(to: time,
                                      toleranceBefore: CMTime.zero,
                                      toleranceAfter: CMTime.zero,
                                      completionHandler: { observer.onNext($0) })
                    return Disposables.create()
                }
            })
            .subscribe(onNext: {
                print("Did it seek properly? \($0)")
            })
            .disposed(by: rx.disposeBag)
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