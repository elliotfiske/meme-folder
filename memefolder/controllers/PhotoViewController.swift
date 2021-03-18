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
        PhotoModel.shared.getPhotoData(for: assetToDisplay!)
            .subscribe(onNext: {
                [weak self] image in
                self?.photoViewer.image = image
            })
            .disposed(by: rx.disposeBag)
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
                                self?.videoPlayer.itemToPlay?.onNext(playerItemUnwrapped)
                               })
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
