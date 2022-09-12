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

import Rswift

class PasteLinkViewController: UIViewController {

    @IBOutlet weak var example1: ExampleButton!
    @IBOutlet weak var example2: ExampleButton!
    @IBOutlet weak var example3: ExampleButton!
    @IBOutlet weak var example4: ExampleButton!
    
    @IBOutlet weak var tweetLinkInput: UITextField!
    @IBOutlet weak var statusLabel: UILabel!

    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var pasteAndGoButton: UIButton!

    @IBOutlet weak var copyExampleTwitterLinkButton: UIButton!

    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!

    @IBAction func populateClipboard2(_ sender: Any) {
        UIPasteboard.general.string =
            "https://twitter.com/hourly_shitpost/status/1564266661573705729"
    }
    
    func presentTweet(url: String) {
        store.dispatch(PreviewTweet(payload: url))

        let controlla = TwitterDLViewController.loadFromNib()
        present(controlla, animated: true)

        statusLabel.text = ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        example1.myImage = R.image.wat()
        example1.myText = "Cool"
        
        example2.myText = "Beans"
        
        example3.myText = "Third one"
        
        example4.myText = "Fourth one"

        rx.disposeBag.insert(
            example1.pressed.subscribe(onNext: {
                [weak self] _ in
                self?.presentTweet(url: "https://twitter.com/meme_folder_app/status/1568385030367449088")
            }),
            
            example2.pressed.subscribe(onNext: {
                [weak self] _ in
                self?.presentTweet(url: "https://twitter.com/meme_folder_app/status/1568385030367449088")
            }),
            
            example3.pressed.subscribe(onNext: {
                [weak self] _ in
                self?.presentTweet(url: "https://twitter.com/meme_folder_app/status/1568385030367449088")
            }),
            
            example4.pressed.subscribe(onNext: {
                [weak self] _ in
                self?.presentTweet(url: "https://twitter.com/meme_folder_app/status/1568385030367449088")
            }),
            
            RxKeyboard.instance.visibleHeight.asObservable()
                .skip(1) // don't animate on first appearance
                .subscribe(onNext: {
                height in

                UIView.animate(
                    withDuration: 0.5,
                    animations: { [weak self] () -> Void in
                        self?.bottomLayoutConstraint.constant = height
                        self?.view.layoutIfNeeded()
                    })
            }),

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
                    controlla.modalPresentationStyle = .popover
                    self?.present(controlla, animated: true)

                    self?.statusLabel.text = ""
                }),

            goButton.rx.tap
                .withLatestFrom(tweetLinkInput.rx.text)
                .compactMap { $0 }
                .subscribe(onNext: {
                    [weak self] url in

                    guard TwitterAPI.getTweetIDFrom(url: url) != nil else {
                        self?.statusLabel.text = "That doesn't seem to be a valid Twitter link."
                        return
                    }

                    store.dispatch(ResetState())
                    store.dispatch(PreviewTweet(payload: url))

                    let controlla = TwitterDLViewController.loadFromNib()
                    self?.present(controlla, animated: true)

                    self?.statusLabel.text = ""
                }),

            copyExampleTwitterLinkButton.rx.tap
                .subscribe(onNext: {
                    UIPasteboard.general.string =
                        "https://twitter.com/MIStoleOffDisc/status/1564010179544457217?s=20&t=dfqr6OOmo3R5Mkp71kLg1A"
                })
        )
    }
}
