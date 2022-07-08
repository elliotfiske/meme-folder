//
//  VideoPlayerViewController.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 2/21/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import Foundation
import UIKit

import RxSwift
import NSObject_Rx
import RxBiBinding

@IBDesignable
public class VideoPlayerViewController: UIView, NibLoadable {
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var videoPlayerView: AVVideoPlayerView!
    @IBOutlet weak var videoControlsView: VideoControlsView!
    
    public lazy var itemToPlay = self.videoPlayerView.itemToPlay
    public lazy var loadingProgress = self.videoPlayerView.loadingProgress
    
    func commonInit() {
        rx.disposeBag.insert([
            videoPlayerView.readyToPlay
                .bind(to: videoControlsView.enabled),
            
            (videoControlsView.isPlaying <-> videoPlayerView.isPlaying),
            
            videoPlayerView.itemLength
                .bind(to: videoControlsView.totalPlaybackLength),
            
            videoPlayerView.currPlaybackTime
                .bind(to: videoControlsView.currPlaybackTime),
            
            videoControlsView.requestedSeekProgress
                .bind(to: videoPlayerView.requestedSeekTime)
        ])
    }
    
    func stopPlaying() {
        videoPlayerView.stop()
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
