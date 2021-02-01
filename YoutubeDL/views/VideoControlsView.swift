//
//  VideoControlsViewController.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 1/26/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//
//  View with a button for play/pause, a timeline view with a "current position"
//      marker, and a time label.
//

import UIKit
import RxCocoa
import RxSwift
import NSObject_Rx

@IBDesignable
public class VideoControlsView: UIView, NibLoadable {
    
    public let isPlaying = BehaviorRelay<Bool>(value: false)
    
    public let currPlaybackTime = BehaviorRelay<CGFloat>(value: 0.0)
    public let totalPlaybackLength = PublishRelay<CGFloat>()
    public let requestedSeekProgress = PublishRelay<CGFloat>()
    
    public var enabled: Binder<Bool> {
        return Binder(self) { [weak self] (controls, isEnabled) in
            self?.alpha = isEnabled ? 1.0 : 0.3
            self?.playPauseButton.isEnabled = isEnabled
        }
    }
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var timelineProgressConstraint: NSLayoutConstraint!
    @IBOutlet weak var timelineBase: RoundedCornerView!
    @IBOutlet weak var currTimeLabel: UILabel!
    
    @IBOutlet weak var timelineDragGesture: UIPanGestureRecognizer!
    
    var timelineLength: CGFloat {
        timelineBase.bounds.size.width
    }
    
    func setupTimelineBehavior() {
        timelineDragGesture.rx.event
            .filter { $0.state == .began }
            .map { _ in false }
            .bind(to: isPlaying)
            .disposed(by: rx.disposeBag)
        
        let dotDraggedToTime = timelineDragGesture.rx.event
            .filter { $0.state == .changed }
            .map { $0.location(in: self.timelineBase).x }
            .map({
                dragLocation in
                return dragLocation.clamped(to: (0...self.timelineLength))
            })
            .distinctUntilChanged()
            
        dotDraggedToTime
            .bind(to: timelineProgressConstraint.rx.constant)
            .disposed(by: rx.disposeBag)
        
        dotDraggedToTime
            .map { $0 / self.timelineLength }
            .map { $0.clamped(to: (0...0.999))}  // Seeking to the very end resets the video to the beginning, for some reason.
            .bind(to: requestedSeekProgress)
            .disposed(by: rx.disposeBag)
        
        Observable.combineLatest(currPlaybackTime, totalPlaybackLength)
            .filter { $1 != 0 }
            .map { $0 / $1 }
            .map { $0 * self.timelineLength }
            .bind(to: timelineProgressConstraint.rx.constant)
            .disposed(by: rx.disposeBag)
    }
    
    func setupTimelineLabel() {
        let oldFont = currTimeLabel.font!
        currTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: oldFont.pointSize, weight: UIFont.Weight.regular)
        
        let totalLengthString = totalPlaybackLength
            .map { Int($0) }
            .distinctUntilChanged()
            .map(durationText)
        
        let currTimeString = currPlaybackTime
            .map { Int($0) }
            .distinctUntilChanged()
            .map(durationText)
        
        Observable.combineLatest(currTimeString, totalLengthString)
            .map { $0 + " / " + $1 }
            .bind(to: currTimeLabel.rx.text)
            .disposed(by: rx.disposeBag)
    }
    
    func setupPlayPauseButton() {
        isPlaying
            .map { playing in
                let imageName = playing ? "pause" : "play"
                let image = UIImage(named:imageName,
                                    in:Bundle(for: type(of: self)),
                                    compatibleWith:nil)!
                return image
            }
            .bind(to: self.playPauseButton.rx.image())
            .disposed(by: rx.disposeBag)
        
        self.playPauseButton.rx.tap
            .subscribe(onNext: {
                self.isPlaying.accept(!self.isPlaying.value)  // Todo: maybe pull this out to an extension?
                //  it could look like tap.toggles(isPlaying)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func commonInit() {
        setupTimelineBehavior()
        setupTimelineLabel()
        setupPlayPauseButton()
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
