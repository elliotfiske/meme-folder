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
    
    @IBOutlet weak var videoPlayerController: VideoPlayerViewController!
    @IBOutlet weak var errorLabel: UILabel!
    
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
        videoPlayerController.itemToPlay.on(.next(item))
    }
    
    func stateDidChange(newState: TwitterMediaModel.MediaState) {
        switch(newState) {
            
        case .idle:
            break
        case .downloadingThumbnail:
            videoPlayerController.loadingProgress.onNext(0.1)
        case .downloadedThumbnail:
            videoPlayerController.loadingProgress.onNext(0.2)
//            thumbnailDisplay.image = model.thumbnailImage
        case .downloadingMedia(let progress):
            videoPlayerController.loadingProgress.onNext(progress)
        case .downloadedMedia:
            videoPlayerController.loadingProgress.onNext(1.0)
//            firstly {     // ahaha this sucks man
//                return UIView.animate(.promise, duration: 0.2) {
//                    self.progressBar.progress = 1.0
//                }
//            }
//            .done { _ in
//                UIView.animate(withDuration: 0.1) {
//                    self.progressBar.alpha = 0.0
//                }
                
                self.setupPlayer()
//            }
        case .savingMediaToCameraRoll:
            break // TODO
        case .finished:
            break // TODO
        }
    }
}
