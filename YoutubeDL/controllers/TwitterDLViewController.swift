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

public class TwitterDLViewController: UIViewController {
    
    public var tweetURLToLoad: String?
    
    var model = TwitterMediaModel()
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var thumbnailDisplay: UIImageView!
    @IBOutlet weak var blurOverlay: UIVisualEffectView!
    
    var silly: UIViewPropertyAnimator?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        model.stateObserver = self
        
        if let tweetURL = tweetURLToLoad {
            model.startDownloadingMedia(forTweetURL: tweetURL)
        }
        
        // create animator to control bliur strength
        self.blurOverlay.effect = nil
        silly = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut, animations: nil)
        
        silly?.addAnimations {
            self.blurOverlay.effect = UIBlurEffect(style: .regular)
        }
        
        // 50% blur
        silly?.fractionComplete = 0.2
    }
}

extension TwitterDLViewController: TwitterMediaModelObserver {
    public func stateDidChange(newState: TwitterMediaModel.MediaState) {
        switch(newState) {
            
        case .idle:
            break
        case .downloadingThumbnail:
            progressBar.setProgress(0.1, animated: true)
        case .downloadedThumbnail:
            progressBar.setProgress(0.2, animated: true)
            thumbnailDisplay.image = model.thumbnailImage
        case .downloadingMedia(_):
            break
        case .downloadedMedia:
            firstly {
                UIView.animate(.promise, duration: 2.2) {
                    self.progressBar.progress = 1.0
                }
            }
            .done { _ in
//                UIView.animate(withDuration: 0.3) {
//                    self.blurOverlay.effect = nil
//                }
                self.silly?.continueAnimation(withTimingParameters: .none, durationFactor: 1.0)
                self.silly?.startAnimation()
            }
        case .savingMediaToCameraRoll:
        break // TODO
        case .finished:
            break // TODO
        }
    }
}
