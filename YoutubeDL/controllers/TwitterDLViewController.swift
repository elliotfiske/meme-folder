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
        model.stateObserver = self
        
        if let tweetURL = tweetURLToLoad {
            model.startDownloadingMedia(forTweetURL: tweetURL)
        }
        
//        videoControlsView.playButtonPresses.subscribe(onNext: {
//
//        })
        videoControlsView.playButtonPresses.bind(to: model.playButtonPressSink)
            .disposed(by: disposeBag)
    }
}

extension TwitterDLViewController: TwitterMediaModelObserver {
    
    // Initialize an AVPlayer with the newly downloaded MP4 file.
    fileprivate func setupPlayer() {
        let item = AVPlayerItem(url: self.model.localMediaURL!)
        player.replaceCurrentItem(with: item)
        
        let superLayer = self.thumbnailDisplay.layer
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.thumbnailDisplay.bounds
        playerLayer.videoGravity = .resizeAspect
        superLayer.addSublayer(playerLayer)
        player.seek(to: CMTime.zero)
        
        player.actionAtItemEnd = .none
        
        model.playerPlaying
            .subscribe(onNext: {
                shouldPlay in
                if shouldPlay {
                    self.player.play()
                } else {
                    self.player.pause()
                }
            })
            .disposed(by: disposeBag)
        
        model.playerPlaying.debug()
            .bind(to: videoControlsView.isPlaying)
        
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
    
    public func stateDidChange(newState: TwitterMediaModel.MediaState) {
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
                UIView.animate(withDuration: 0.2) {
                    self.progressBar.alpha = 0.0
                }
                
                self.setupPlayer()
            }
        case .savingMediaToCameraRoll:
        break // TODO
        case .finished:
            break // TODO
        }
    }
}
