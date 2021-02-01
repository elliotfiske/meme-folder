//
//  ViewController.swift
//  memefolder
//
//  Created by Elliot Fiske on 1/3/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import UIKit
import PMKAlamofire
import PromiseKit

import AVKit
import AVFoundation

import RxCocoa
import RxSwift
import NSObject_Rx

public class TwitterDLViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    public var tweetURLToLoad: String?
    
    let model = TwitterMediaModel()
    
    @IBOutlet weak var videoPlayerController: VideoPlayerViewController!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var saveToCameraRollButton: UIButton!
    
    deinit {
    }
    
    public override func willMove(toParent parent: UIViewController?) {
        self.parent?.presentationController?.delegate = self
    }
    
    public func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        print("hey there")
        videoPlayerController.stopPlaying()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if let tweetURL = tweetURLToLoad {
            model.startDownloadingMedia(forTweetURL: tweetURL)
        }
        
        model.state
            .subscribe(onNext: {
                [weak self] state in
                self?.stateDidChange(newState: state)
            })
            .disposed(by: rx.disposeBag)
        
        saveToCameraRollButton.rx.tap
            .subscribe(onNext: {
                [weak self] in
                self?.model.saveMediaToCameraRoll()
            })
            .disposed(by: rx.disposeBag)
    }
}

extension TwitterDLViewController {
    
    // Initialize an AVPlayer with the newly downloaded MP4 file.
    // TODO: pull me out to my own bona-fide view, and do the AV layer stuff in there.
    func setupPlayer() {
        let item = AVPlayerItem(url: self.model.localMediaURL!)
        videoPlayerController.itemToPlay?.on(.next(item))
    }
    
    func stateDidChange(newState: TwitterMediaModel.MediaState) {
        switch(newState) {
        case .downloadedMedia, .error:
            self.saveToCameraRollButton.isEnabled = true
        default:
            self.saveToCameraRollButton.isEnabled = false
        }
        
        switch(newState) {
        case .error:
            self.saveToCameraRollButton.titleLabel?.text = "Retry..."
        default:
            self.saveToCameraRollButton.titleLabel?.text = "Save to Camera Roll"
        }
        
        switch(newState) {
        case .savingMediaToCameraRoll:
            self.successLabel.text = "Saving..."
            self.successLabel.textColor = UIColor.label
            self.successLabel.isHidden = false
        case .finished:
            self.successLabel.text = "Success!"
            self.successLabel.textColor = UIColor.systemGreen
            self.successLabel.isHidden = false
        default:
            self.successLabel.isHidden = true
        }
        
        switch(newState) {
        
        case .idle:
            break
        case .downloadingThumbnail:
            videoPlayerController.loadingProgress.onNext(0.1)
        case .downloadedThumbnail:
            videoPlayerController.loadingProgress.onNext(0.2)
        //            thumbnailDisplay.image = model.thumbnailImage
        case .downloadingMedia(let progress):
            videoPlayerController.loadingProgress.onNext(progress)
        case .downloadedMedia:
            videoPlayerController.loadingProgress.onNext(1.0)
            //            firstly {     // ahaha this sucks man
            //                return UIView.animate(.promise, duration: 0.2) {
            //                    self.progressBar.progress = 1.0
            //                }
            //            }
            //            .done { _ in
            //                UIView.animate(withDuration: 0.1) {
            //                    self.progressBar.alpha = 0.0
            //                }
            
            self.setupPlayer()
        //            }
        case .savingMediaToCameraRoll:
            //            successLabel.text = "Saving..."
            break
        case .finished:
            //            successLabel.text = "Saved to camera roll!"
            break
        case .error(let err):
            errorLabel.text = err.localizedDescription
        }
    }
}
