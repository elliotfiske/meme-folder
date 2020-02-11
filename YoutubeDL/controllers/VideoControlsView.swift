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
    
    //
    //      weiird stuff abounds. Will clean up shortly.
    //
    //          I like Rx for handling UI state and interactions,
    //          but I like Promises more for handling network
    //          and async calls (like asking the user for permission).
    //
    //          I THINK the two systems should play nice together.
    //
    public let isPlaying = BehaviorRelay<Bool>(value: false)
    
    public let currPlaybackTime = BehaviorRelay<CGFloat>(value: 0.0)
    
    // TODO: Pull this out to an extension (I think one might already exist in RxSwift somewhere?) ((i was thinking of NSObject+Rx.swift))
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var timelineProgressConstraint: NSLayoutConstraint!
    @IBOutlet weak var timelineBase: RoundedCornerView!
    
    @IBAction func draggedOnTimeline(_ sender: UIPanGestureRecognizer) {
        let loc = sender.location(in: sender.view!)
        
        timelineProgressConstraint.constant = loc.x
    }
    
    func commonInit() {
        currPlaybackTime
            .map { $0 * self.timelineBase.bounds.size.width / 2 }   // TODO: Why doesn't this line up? grrr.
            .bind(to: timelineProgressConstraint.rx.constant)
            .disposed(by: disposeBag)
        
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
