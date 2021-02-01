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

@IBDesignable
public class VideoPlayerViewController: UIView, NibLoadable {
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var videoPlayerView: AVVideoPlayerView!
    @IBOutlet weak var videoControlsView: VideoControlsView!
    
    public lazy var itemToPlay = self.videoPlayerView.itemToPlay
    public lazy var loadingProgress = self.videoPlayerView.loadingProgress
    
    func commonInit() {
        videoPlayerView.readyToPlay
            .bind(to: videoControlsView.enabled)
            .disposed(by: rx.disposeBag)
        
        (videoControlsView.isPlaying <-> videoPlayerView.isPlaying)
            .disposed(by: rx.disposeBag)
        
        videoPlayerView.itemLength
            .bind(to: videoControlsView.totalPlaybackLength)
            .disposed(by: rx.disposeBag)
        
        videoPlayerView.currPlaybackTime
            .bind(to: videoControlsView.currPlaybackTime)
            .disposed(by: rx.disposeBag)
        
        videoControlsView.requestedSeekProgress
            .bind(to: videoPlayerView.requestedSeekTime)
            .disposed(by: rx.disposeBag)
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
