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

@IBDesignable
public class VideoControlsView: UIView, NibLoadable {
    
    // TODO: Move state to a controller (or even better a model)
    public private(set) var isPlaying: Bool = false
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBAction func playPauseTapped(_ sender: Any) {
        isPlaying = !isPlaying
        
        
        
        let newImageName = isPlaying ? "play" : "pause"
        if let newImage = UIImage(named: newImageName, in:Bundle(for: type(of: self)), compatibleWith:nil) {
            playPauseButton.setImage(newImage, for: .normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }
}
