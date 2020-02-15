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

@IBDesignable
public class VideoControlsView: UIView, NibLoadable {
    
    public let isPlaying = BehaviorRelay<Bool>(value: false)
    
    public let currPlaybackTime = BehaviorRelay<CGFloat>(value: 0.0)
    public let totalPlaybackLength = PublishRelay<CGFloat>()
    public let requestedSeekProgress = PublishRelay<CGFloat>()
    
    // TODO: Pull this out to an extension (I think one might already exist in RxSwift somewhere?) ((i was thinking of NSObject+Rx.swift))
    let disposeBag = DisposeBag()
    
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
            .disposed(by: disposeBag)
        
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
            .disposed(by: disposeBag)
        
        dotDraggedToTime
            .map { $0 / self.timelineLength }
            .bind(to: requestedSeekProgress)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(currPlaybackTime, totalPlaybackLength)
            .map { $0 / $1 }
            .map { $0 * self.timelineLength }
            .bind(to: timelineProgressConstraint.rx.constant)
            .disposed(by: disposeBag)
    }
    
    func setupTimelineLabel() {
        let totalLengthString = totalPlaybackLength
            .map { Int($0) - 1 }
            .distinctUntilChanged()
            .map(durationText)
        
        let currTimeString = currPlaybackTime
            .map { Int($0) }
            .distinctUntilChanged()
            .map(durationText)
        
        Observable.combineLatest(currTimeString, totalLengthString)
            .map { $0 + " / " + $1 }
            .bind(to: currTimeLabel.rx.text)
            .disposed(by: disposeBag)
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
            .disposed(by: disposeBag)
        
        self.playPauseButton.rx.tap
            .subscribe(onNext: {
                self.isPlaying.accept(!self.isPlaying.value)  // Todo: maybe pull this out to an extension?
                //  it could look like tap.toggles(isPlaying)
            })
            .disposed(by: disposeBag)
    }
    
    func commonInit() {
        let oldFont = currTimeLabel.font!
        currTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: oldFont.pointSize, weight: UIFont.Weight.regular)
        
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
