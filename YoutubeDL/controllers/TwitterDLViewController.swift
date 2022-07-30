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
    
    @IBOutlet weak var filesizeButton1: FilesizeButton!
    @IBOutlet weak var filesizeButton2: FilesizeButton!
    @IBOutlet weak var filesizeButton3: FilesizeButton!
    
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
        
        store.observableFromPath(keyPath: \.sizeForUrl)
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map {
                sizes -> [(url: String, size: Int)] in
                var result = [(url: String, size: Int)]()
                for (url, size) in sizes {
                    result.append((url: url, size: size))
                }
                
                result.sort(by: {
                    a, b in
                    a.size < b.size
                })
                
                return result
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                [weak self] filesizes in
                
                let buttons = [self?.filesizeButton1, self?.filesizeButton2, self?.filesizeButton3]
                buttons.forEach {
                    $0?.isHidden = true
                }
                
                for (ndx, (url, size)) in filesizes.enumerated() {
                    let button = buttons[ndx]
                    let groups = url.groups(for: "/(\\d+)x(\\d+)/")
                    button?.dimensions.text = "\(groups.get(index: 0)?.get(index: 1) ?? "?") x \(groups.get(index: 0)?.get(index: 2) ?? "?")"
                    button?.filesize.text = ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
                    button?.isHidden = false
                }
            })
            .disposed(by: rx.disposeBag)
        
        
        
        
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
            
            store.observableFromPath(keyPath: \.mediaResultURL).apiResult()
                .observe(on: MainScheduler.instance)
                .compactMap {
                    if case let .videos(thumbnail: thumb, urls: _) = $0 {
                        return thumb
                    }
                    return nil
                }
                .distinctUntilChanged()
                .subscribe(onNext: {
                    [weak self] (thumb: String) in
                    self?.videoPlayerController.thumbnailView.source = thumb
                }),
            
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
                .bind(to: videoPlayerController.itemToPlay),
            
            store.observableFromPath(keyPath: \.downloadedMediaProgress)
                .map { Float($0) }
                .bind(to: videoPlayerController.loadingProgress)
        )
        
    }
}
