//
//  InitialViewController.swift
//  memefolder
//
//  Created by Elliot Fiske on 1/10/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import UIKit
import YoutubeDL

class InitialViewController: UIViewController {
    @IBAction func buttonPressed(_ sender: Any) {
        let controlla = TwitterDLViewController.loadFromNib()
        
        // Simulates getting a Tweet URL via the Share panel and passing it along
//        controlla.tweetURLToLoad = "https://twitter.com/animatedtext/status/1220134801430024193?s=20"     // 0:03 video
        
//        controlla.tweetURLToLoad = "https://twitter.com/CultureCrave/status/1226622427599257601"          // 0:16 video
        
        controlla.tweetURLToLoad = "https://twitter.com/tortellinidance/status/1217858057201504257?s=20"    // 1:30 video
        
        present(controlla, animated: true)
    }
}
