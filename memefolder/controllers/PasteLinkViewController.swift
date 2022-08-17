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

    override func viewDidLoad() {
        super.viewDidLoad()

        let isValidTwitterLink = tweetLinkInput.rx.text.map {
            url -> Bool in
            guard let url = url else { return false }
            return TwitterAPI.getTweetIDFrom(url: url) != nil
        }

        rx.disposeBag.insert(
            isValidTwitterLink
                .filter { $0 }
                .withLatestFrom(tweetLinkInput.rx.text)
                .compactMap { $0 }
                .debounce(.milliseconds(200), scheduler: MainScheduler.instance)
                .distinctUntilChanged()
                .subscribe(onNext: {
                    url in
                    store.dispatch(PreviewTweet(payload: url))
                }),

            store.observableFromPath(keyPath: \.mediaResultURL)
                .apiResult()
                .map { $0.videos }
                .distinctUntilChanged()
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: {
                    [weak self] _ in
                    self?.statusLabel.text = "success yo!"
                    let controlla = TwitterDLViewController.loadFromNib()
                    self?.present(controlla, animated: true)
                }),

            store.observableFromPath(keyPath: \.mediaResultURL)
                .apiError()
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: {
                    [weak self]
                    err in
                    self?.statusLabel.text = err.localizedDescription
                }),

            isValidTwitterLink.map {
                $0 ? "Valid Twitter link, checking for media..." : "Not a Twitter link!"
            }
            .withLatestFrom(tweetLinkInput.rx.text) {
                (message, text) in
                guard let text = text, text.count > 0 else {
                    return ""
                }
                return message
            }
            .bind(to: statusLabel.rx.text)
        )

    }
}
