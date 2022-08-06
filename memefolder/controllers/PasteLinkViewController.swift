//
//  PasteLinkViewController.swift
//  memefolder
//
//  Created by Elliot Fiske on 8/2/22.
//  Copyright © 2022 Meme Folder. All rights reserved.
//

import UIKit
import YoutubeDL
import RxSwift

class PasteLinkViewController: UIViewController {
    
    @IBOutlet weak var tweetLinkInput: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    
//    static func coolFunction(url: String) -> Observable<TwitterAPI.MediaResultURLs> {
//        return Observable.just("hi").flatMap({
//            (foo: String) -> Observable<TwitterAPI.MediaResultURLs> in
//            return try TwitterAPI.sharedInstance.getMediaURLsRx(for: url)
//        })
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let isValidTwitterLink = tweetLinkInput.rx.text.map {
            url -> Bool in
            guard let url = url else { return false }
            return TwitterAPI.getTweetIDFrom(url: url) != nil
        }
        
        isValidTwitterLink
            .filter {$0}
            .withLatestFrom(tweetLinkInput.rx.text)
            .compactMap {$0}
            .debounce(.milliseconds(200), scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                url in
                store.dispatch(GetMediaURLsFromTweet(payload: url))
            })
            .disposed(by: rx.disposeBag)
        
        store.observableFromPath(keyPath: \.mediaResultURL)
            .apiResult()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                [weak self] _ in
                self?.statusLabel.text = "success yo!"
                let controlla = TwitterDLViewController.loadFromNib()
                self?.present(controlla, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        store.observableFromPath(keyPath: \.mediaResultURL)
            .apiError()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self]
                err in
                self?.statusLabel.text = err.localizedDescription
            })
            .disposed(by: rx.disposeBag)
        
        
        isValidTwitterLink.map {
            $0 ? "Valid Twitter link, checking for media..." : "Not a Twitter link!"
        }
            .bind(to: statusLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
//        let media: Observable<TwitterAPI.MediaResultURLs?> = input
//            .flatMapLatest {
//                url -> Observable<TwitterAPI.MediaResultURLs> in
//                return PasteLinkViewController.coolFunction(url: url)
//            }
//            .flatMapLatest {
//                (url: String) -> Observable<TwitterAPI.MediaResultURLs?> in
//                return Observable.just("hi").flatMap {
//                    (foo: String) -> Observable<TwitterAPI.MediaResultURLs> in
//                    return try TwitterAPI.sharedInstance.getMediaURLsRx(for: url)
//                }.catchErrorJustReturn(nil)
//            }
        
//        media.map {
//            (urls: TwitterAPI.MediaResultURLs?) -> String in
//            urls == nil ? "No media!" : "There's media!"
//        }
//        .bind(to: statusLabel.rx.text)
//        .disposed(by: rx.disposeBag)
        
    }
}
