//
//  ShareViewController.swift
//  gifgrabber
//
//  Created by Elliot Fiske on 1/3/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import UIKit
import Social

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
            }
        }
        
        // dismiss the share panel thingy
//        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

}
