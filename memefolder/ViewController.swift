//
//  ViewController.swift
//  memefolder
//
//  Created by Elliot Fiske on 1/3/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import UIKit
import YoutubeDL

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TwitterDL.sharedInstance.extractMediaURLs(usingTweetURL: "https://twitter.com/pokimanelol/status/1213551994964606976?s=20")
            .catch { error in
                switch error {
                case let error as TwitterAPIError:
                    print("Had some kinda internet issue :(")
                default:
                    print("Unknown error!!")
                }
        }
    }
}

