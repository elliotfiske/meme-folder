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
        let activityVC = UIActivityViewController(activityItems: ["Hello, world!", URL(string: "https://nshipster.com")!], applicationActivities: nil)
        
        let testView = UIView(frame: CGRect(x: 178, y: 182, width: 78, height: 60))
        testView.backgroundColor = .systemGray
        
        let dumbLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 78, height: 60))
        dumbLabel.text = "Tap here -->"
        dumbLabel.font = UIFont.systemFont(ofSize: 8)
        testView.addSubview(dumbLabel)
        
        activityVC.view.addSubview(testView)
        
        present(activityVC, animated: true)
    }
}
