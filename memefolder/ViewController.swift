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
        
        TwitterDL.sharedInstance.callAPI()
    }
}

