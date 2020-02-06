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
    public let isPlaying = PublishRelay<Bool>()
    
    lazy public var playButtonPresses = self.playPauseButton.rx.tap
    
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
        isPlaying.subscribe(onNext: { playing in
            let imageName = playing ? "pause" : "play"
            let image = UIImage(named:imageName,
                                in:Bundle(for: type(of: self)),
                                compatibleWith:nil)!
            self.playPauseButton.setImage(image, for: .normal)
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
