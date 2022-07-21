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
          if case let .videos(thumbnail: _, urls: urls) = $0 {
            return urls.joined(separator: ", ")
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
        .bind(to: errorLabel.rx.isHidden),

      store.observableFromPath(keyPath: \.mediaResultURL)
        .map { $0.getResult() == nil }
        .bind(to: successLabel.rx.isHidden),

      saveToCameraRollButton.rx.tap.withLatestFrom(
        store.observableFromPath(keyPath: \.mediaResultURL).apiResult()
      )
      .subscribe(onNext: {
          result in
          if case let .videos(thumbnail: _, urls: urls) = result {
              store.dispatch(TwitterAPIAction.downloadMedia(url: urls.last!))
          }
      }),
      
      store.observableFromPath(keyPath: \.localMediaURL).apiResult()
        .map {
            url in
            return AVPlayerItem(url: url)
        }
        .bind(to: videoPlayerController.itemToPlay!),
      
      store.observableFromPath(keyPath: \.downloadedMediaProgress)
        .map { Float($0) }
        .bind(to: videoPlayerController.loadingProgress)
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
}
