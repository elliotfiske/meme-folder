//
//  AVVideoPlayerView.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 2/21/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import RxSwift
import RxRelay

class AVVideoPlayerView: UIView, NibLoadable {
    
    public let readyToPlay = PublishRelay<Bool>()
    
    public var itemToPlay: Binder<AVPlayerItem> {
        return Binder(self.player) { [weak self] (player, newItem) in
            player.replaceCurrentItem(with: newItem)
            self?.readyToPlay.accept(false)
        }
    }
    
    let player = AVPlayer()
    var playerLayer: AVPlayerLayer!
    
    let disposeBag = DisposeBag() // TODO-EF: Extensionize me, baby
    
    func commonInit() {
        playerLayer = AVPlayerLayer(player: self.player)
        
        playerLayer.videoGravity = .resizeAspect
        self.layer.addSublayer(playerLayer)
        
        player.actionAtItemEnd = .none
        player.seek(to: CMTime.zero)
        
        self.player.rx.status
            .map { $0 == .readyToPlay }
            .bind(to: self.readyToPlay)
            .disposed(by: disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.playerLayer.bounds = self.bounds
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
