//
//  PhotoViewController.swift
//  memefolder
//
//  Created by Elliot Fiske on 3/2/21.
//  Copyright © 2021 Meme Folder. All rights reserved.~
//

import UIKit
import Photos

import YoutubeDL

class PhotoViewController: UIViewController {

    @IBOutlet weak var photoViewer: UIImageView!
    @IBOutlet weak var videoPlayer: VideoPlayerViewController!

    public var assetToDisplay: PHAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let asset = assetToDisplay else {
            // TODO-EF: also throw an error or something I guess?
            return
        }
        
        switch asset.mediaType {
        case .image:
            photoViewer.isHidden = false
            videoPlayer.isHidden = true
            loadPhoto()
        case .video:
            photoViewer.isHidden = true
            videoPlayer.isHidden = false
            loadVideo()
        case .audio, .unknown:
            // TODO-EF: handle this, eventually, maybe...
            return
        @unknown default:
            fatalError("New type of asset discovered! Amazing! \(asset.mediaType)")
        }
    }
    
    func loadPhoto() {
        guard let asset = assetToDisplay else {
            return
        }
        
        let requestId = PHImageManager
            .default()
            .requestImage(for: asset, targetSize: self.view.bounds.size, contentMode: .aspectFit, options: nil, resultHandler: {
                [weak self] image, infoDict in
                guard image != nil else {
//                    subscriber.onError(PhotoRetrievalError(message: "Oh no some kind of error! Didn't get the photo data!"))
                    return
                }

                self?.photoViewer.image = image
            })
    }
    
    func loadVideo() {
        PHImageManager
            .default()
            .requestPlayerItem(forVideo: assetToDisplay!,
                               options: nil,
                               resultHandler: {
                                [weak self] playerItem, dict in
                                guard let playerItemUnwrapped = playerItem else {
                                    // TODO-EF: Error time, baby
                                    return
                                }
                                self?.videoPlayer.itemToPlay.onNext(playerItemUnwrapped)
                               })
    }
}
