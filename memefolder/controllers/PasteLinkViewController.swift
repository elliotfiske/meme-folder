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

    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var pasteAndGoButton: UIButton!

    @IBOutlet weak var copyExampleTwitterLinkButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        let isValidTwitterLink = tweetLinkInput.rx.text.map {
            url -> Bool in
            guard let url = url else { return false }
            return TwitterAPI.getTweetIDFrom(url: url) != nil
        }

        rx.disposeBag.insert(
            isValidTwitterLink
                .bind(to: goButton.rx.isEnabled),

            pasteAndGoButton.rx.tap
                .subscribe(onNext: {
                    [weak self] _ in

                    guard
                        let url = UIPasteboard.general.string
                            ?? UIPasteboard.general.url?.absoluteString
                    else {
                        self?.statusLabel.text = "No Twitter link in your Clipboard"
                        return
                    }

                    store.dispatch(PreviewTweet(payload: url))

                    let controlla = TwitterDLViewController.loadFromNib()
                    self?.present(controlla, animated: true)

                    self?.statusLabel.text = ""
                }),

            goButton.rx.tap
                .withLatestFrom(tweetLinkInput.rx.text)
                .compactMap { $0 }
                .subscribe(onNext: {
                    [weak self] url in

                    guard TwitterAPI.getTweetIDFrom(url: url) != nil else {
                        self?.statusLabel.text = "That doesn't seem to be a valid Twitter link"
                        return
                    }

                    store.dispatch(PreviewTweet(payload: url))

                    let controlla = TwitterDLViewController.loadFromNib()
                    self?.present(controlla, animated: true)

                    self?.statusLabel.text = ""
                }),

            copyExampleTwitterLinkButton.rx.tap
                .subscribe(onNext: {
                    UIPasteboard.general.string =
                        "https://twitter.com/matthen2/status/1543226572592783362"
                })
        )
    }
}
