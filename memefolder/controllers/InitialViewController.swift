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
    @IBOutlet weak var recentPhotosContainer: UIView!
    
    var recentPhotosController: RecentPhotosCollectionViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: I'll almost certainly need to do this again so I should make a helper for it.
        
        let storyboard = UIStoryboard(name: "RecentPhotosCollectionViewController", bundle: nil)
        guard let controller = storyboard.instantiateInitialViewController() else {
            return
        }
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(controller)
        recentPhotosContainer.addSubview(controller.view)
        
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: recentPhotosContainer.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: recentPhotosContainer.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: recentPhotosContainer.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: recentPhotosContainer.bottomAnchor)
        ])
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        let controlla = TwitterDLViewController.loadFromNib()
        
        // Simulates getting a Tweet URL via the Share panel and passing it along
//        controlla.tweetURLToLoad = "https://twitter.com/animatedtext/status/1220134801430024193?s=20"     // 0:03 gif
        
//        controlla.tweetURLToLoad = "https://twitter.com/CultureCrave/status/1226622427599257601"          // 0:16 video
        
        controlla.tweetURLToLoad = "https://twitter.com/cyberglittter/status/1413344653408153600?s=20" // 2 Images
        
//        controlla.tweetURLToLoad = "https://twitter.com/tortellinidance/status/1217858057201504257?s=20"    // 1:30 video
        
        
        controlla.presentationController?.delegate = controlla
        present(controlla, animated: true)
        
    }
}
