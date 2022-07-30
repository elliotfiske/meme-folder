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
import RxRelay
import NSObject_Rx
import RxBiBinding

import NukeUI
import AVFoundation

extension NSLayoutConstraint {
    /**
     Change multiplier constraint

     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
    */
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {

        NSLayoutConstraint.deactivate([self])

        let newConstraint = NSLayoutConstraint(
            item: firstItem!,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)

        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier

        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}

@IBDesignable
public class VideoPlayerViewController: UIView, NibLoadable {
    @IBOutlet weak var thumbnailView: LazyImageView!
    @IBOutlet weak var videoPlayerView: AVVideoPlayerView!
    @IBOutlet weak var videoControlsView: VideoControlsView!
    @IBOutlet weak var aspectRatioConstraint: NSLayoutConstraint!
    
    public lazy var itemToPlay = self.videoPlayerView.itemToPlay
    
    public lazy var loadingProgress = self.videoPlayerView.loadingProgress
    
    func commonInit() {
        
        thumbnailView.placeholderView = UIActivityIndicatorView()
        
        rx.disposeBag.insert([
            Observable.create {
                [weak self] observer in
                self?.thumbnailView.onSuccess = {
                    response in
                    observer.onNext(response.image.size.width / response.image.size.height)
                }
                
                return Disposables.create()
            }.subscribe(onNext: {
                [weak self] (ratio: CGFloat) in
                self?.aspectRatioConstraint = self?.aspectRatioConstraint.setMultiplier(multiplier: ratio)
            }),
//
//            itemToPlay
//                .flatMap {
//                    item in
//                    return item.rx.observeWeakly(CGSize.self, "presentationSize")
//                }
//                .subscribe(onNext: {
//                    [weak self] (size: CGSize?) in
//                    if let size = size {
//                        self?.aspectRatioConstraint.constant = size.width / size.height
//                    }
//                }),
            
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
