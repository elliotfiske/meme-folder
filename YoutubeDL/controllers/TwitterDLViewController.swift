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
    @IBOutlet weak var imageLoadingActivityIndicator: UIActivityIndicatorView!
    
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
    public func stateDidChange(newState: TwitterMediaModel.MediaState) {
        switch(newState) {
            
        case .idle: break
        case .downloadingThumbnail:
            imageLoadingActivityIndicator.startAnimating()
        case .downloadedThumbnail:
            imageLoadingActivityIndicator.stopAnimating()
            thumbnailDisplay.image = model.thumbnailImage
        case .downloadingMedia(_):
            break
        case .downloadedMedia:
        break // TODO
        case .savingMediaToCameraRoll:
        break // TODO
        case .finished:
            break // TODO
        }
    }
}
