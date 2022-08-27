//
//  ShareViewController.swift
//  shareExtension
//
//  Created by Elliot Fiske on 1/3/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import UIKit
import Social
import YoutubeDL

class ShareViewController: UIViewController {

    override func viewDidLoad() {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem else {
            return
        }

        guard let itemProvider = item.attachments?.first else {
            return
        }

        guard itemProvider.hasItemConformingToTypeIdentifier("public.url") else {
            return
        }

        itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { (url, error) in
            if let shareURL = url as? NSURL {
                print(shareURL)

                DispatchQueue.main.async {
                    let controlla = TwitterDLViewController.loadFromNib()
                    let tweetURL = shareURL.absoluteString

                    store.dispatch(PreviewTweet(payload: tweetURL!))

                    self.addChild(controlla)
                    controlla.view.frame = self.view.frame
                    self.view.addSubview(controlla.view)
                    controlla.didMove(toParent: self)
                }
            }
        }

        // dismiss the share panel thingy
        //        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

}
