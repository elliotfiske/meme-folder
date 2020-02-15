//
//  ViewController.swift
//  memefolder
//
//  Created by Elliot Fiske on 1/3/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import UIKit
import PMKAlamofire
import PromiseKit

import AVKit
import AVFoundation

import RxCocoa
import RxSwift

public class TwitterDLViewController: UIViewController {
    
    public var tweetURLToLoad: String?
    
    let model = TwitterMediaModel()
    
    let disposeBag = DisposeBag()
    
    let player = AVPlayer()
    
    @IBOutlet weak var videoControlsView: VideoControlsView!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var thumbnailDisplay: UIImageView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if let tweetURL = tweetURLToLoad {
            model.startDownloadingMedia(forTweetURL: tweetURL)
        }
        
        model.state
            .subscribe(onNext: self.stateDidChange)
            .disposed(by: disposeBag)
    }
}

extension TwitterDLViewController {
    
    // Initialize an AVPlayer with the newly downloaded MP4 file.
    // TODO: pull me out to my own bona-fide view, and do the AV layer stuff in there.
    func setupPlayer() {
        let item = AVPlayerItem(url: self.model.localMediaURL!)
        player.replaceCurrentItem(with: item)
        
        let superLayer = self.thumbnailDisplay.layer
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.thumbnailDisplay.bounds
        playerLayer.videoGravity = .resizeAspect
        superLayer.addSublayer(playerLayer)
        player.seek(to: CMTime.zero)
        
        player.actionAtItemEnd = .none
        
        (model.playerIsPlaying <-> videoControlsView.isPlaying)
            .disposed(by: disposeBag)
        
        model.playerIsPlaying
            .bind(to: player.rx.isPlaying)
            .disposed(by: disposeBag)
        
        let lengthInSeconds = CGFloat(CMTimeGetSeconds(item.asset.duration))
        
        videoControlsView.totalPlaybackLength
            .accept(lengthInSeconds)
        
        videoControlsView.requestedSeekProgress
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .flatMap({
                progress -> Observable<Bool> in
                let secs = Double(lengthInSeconds * progress)
                let time = CMTime(seconds: secs, preferredTimescale: 600)
                
                return Observable<Bool>.create {
                    observer in
                    self.player.seek(to: time,
                                     toleranceBefore: CMTime.zero,
                                     toleranceAfter: CMTime.zero,
                                     completionHandler: { observer.onNext($0) })
                    return Disposables.create()
                }
            })
            .subscribe(onNext: {
                print("Did it? \($0)")
            })
            .disposed(by: disposeBag)
        
        player.rx.periodicTimeObserver(interval: CMTime(value: 1, timescale: 10))
            .map { CGFloat(CMTimeGetSeconds($0)) }
            .bind(to: videoControlsView.currPlaybackTime)
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            .subscribe(onNext: {
                notification in
                if let playerItem = notification.object as? AVPlayerItem {
                    playerItem.seek(to: CMTime.zero, completionHandler: nil)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func stateDidChange(newState: TwitterMediaModel.MediaState) {
        switch(newState) {
            
        case .idle:
            break
        case .downloadingThumbnail:
            progressBar.setProgress(0.1, animated: false)
        case .downloadedThumbnail:
            progressBar.setProgress(0.2, animated: false)
            thumbnailDisplay.image = model.thumbnailImage
        case .downloadingMedia(let progress):
            progressBar.setProgress(Float(progress), animated: false)
            break
        case .downloadedMedia:
            firstly {
                return UIView.animate(.promise, duration: 0.2) {
                    self.progressBar.progress = 1.0
                }
            }
            .done { _ in
                UIView.animate(withDuration: 0.1) {
                    self.progressBar.alpha = 0.0
                }
                
                self.setupPlayer()
                
                // Start playing when loaded
                self.model.playerIsPlaying.accept(true)
            }
        case .savingMediaToCameraRoll:
        break // TODO
        case .finished:
            break // TODO
        }
    }
}
