//
//  DummyTestViewController.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 8/30/22.
//  Copyright © 2022 Meme Folder. All rights reserved.
//

import Foundation
import UIKit

public class DummyTestViewController: UIViewController {
    
    public var counter = 0
    
    @IBOutlet weak var counterLabel: UILabel!
    
    
    @IBAction func dummyButtonPress(_ sender: Any) {
        counter += 1
        
        counterLabel.text = "\(counter)"
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        print("view loaded!")
    }
}
