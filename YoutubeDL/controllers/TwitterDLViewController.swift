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

public class TwitterDLViewController: UIViewController {
    
    public var tweetURLToLoad: String?
    
    var model = TwitterMediaModel()
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var thumbnailDisplay: UIImageView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        model.stateObserver = self
        
        if let tweetURL = tweetURLToLoad {
            model.startDownloadingMedia(forTweetURL: tweetURL)
        }
    }
}

extension TwitterDLViewController: TwitterMediaModelObserver {
    
    // Initialize an AVPlayer with the newly downloaded MP4 file.
    fileprivate func setupPlayer() {
        let item = AVPlayerItem(url: self.model.localMediaURL!)
        let player = AVPlayer(playerItem: item)
        
        let superLayer = self.thumbnailDisplay.layer
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.thumbnailDisplay.bounds
        playerLayer.videoGravity = .resizeAspect
        superLayer.addSublayer(playerLayer)
        player.seek(to: CMTime.zero)
        player.play()
        
        player.actionAtItemEnd = .none
        
        NotificationCenter.default
            .addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                         object: player.currentItem,
                         queue: OperationQueue.main,
                         using: {
                            notification in
                            if let playerItem = notification.object as? AVPlayerItem {
                                playerItem.seek(to: CMTime.zero, completionHandler: nil)
                            }
            })
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
