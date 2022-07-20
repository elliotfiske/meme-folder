//
//  ViewController.swift
//  memefolder
//
//  Created by Elliot Fiske on 1/3/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import AVFoundation
import AVKit
import NSObject_Rx
import RxCocoa
import RxSwift
import UIKit

public class TwitterDLViewController: UIViewController, UIAdaptivePresentationControllerDelegate {

  public var tweetURLToLoad: String?

  let model = TwitterMediaModel()

  @IBOutlet weak var videoPlayerController: VideoPlayerViewController!
  @IBOutlet weak var errorLabel: UILabel!
  @IBOutlet weak var successLabel: UILabel!
  @IBOutlet weak var saveToCameraRollButton: UIButton!

  public override func willMove(toParent parent: UIViewController?) {
    super.willMove(toParent: parent)
    self.parent?.presentationController?.delegate = self
  }

  public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    print("hey there")
    videoPlayerController.stopPlaying()
  }

  override public func viewDidLoad() {
    super.viewDidLoad()

    if let tweetURL = tweetURLToLoad {
      store.dispatch(TwitterAPIAction.getMediaFromTweet(tweetURL))
    }

    rx.disposeBag.insert(
      store.observableFromPath(keyPath: \.mediaResultURL)
        .apiResult()
        .compactMap {
          if case let .videos(thumbnail: thumb, urls: _) = $0 {
            return thumb
          }
          return nil
        }
        .bind(to: successLabel.rx.text),

      store.observableFromPath(keyPath: \.mediaResultURL)
        .apiError()
        .map {
          $0.localizedDescription
        }
        .bind(to: errorLabel.rx.text),

      store.observableFromPath(keyPath: \.mediaResultURL)
        .map { $0.getError() == nil }
        .bind(to: errorLabel.rx.isHidden)
    )

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
    switch newState {
    case .downloadedMedia, .error:
      self.saveToCameraRollButton.isEnabled = true
    default:
      self.saveToCameraRollButton.isEnabled = false
    }

    switch newState {
    case .error:
      self.saveToCameraRollButton.titleLabel?.text = "Retry..."
    default:
      self.saveToCameraRollButton.titleLabel?.text = "Save to Camera Roll"
    }

    switch newState {
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

    switch newState {

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
