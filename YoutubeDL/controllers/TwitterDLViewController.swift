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
    }
}

extension TwitterDLViewController: TwitterMediaModelObserver {
    public func stateDidChange(newState: TwitterMediaModel.MediaState) {
        switch(newState) {
            
        case .idle:
            break
        case .downloadingThumbnail:
            progressBar.setProgress(0.1, animated: false)
        case .downloadedThumbnail:
            progressBar.setProgress(0.2, animated: false)
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
                UIView.animate(withDuration: 0.5) {
                    let layer = self.progressBar.layer
                    
                    let hideProgressBarAnim = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
                    hideProgressBarAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    hideProgressBarAnim.duration = 0.5
                    hideProgressBarAnim.fromValue = layer.transform
                    hideProgressBarAnim.toValue = CATransform3DMakeTranslation(0, -10, 0)
                    layer.add(hideProgressBarAnim, forKey: "hideMe")
                }

            }
        case .savingMediaToCameraRoll:
        break // TODO
        case .finished:
            break // TODO
        }
    }
}
