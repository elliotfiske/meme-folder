//
//  ViewController.swift
//  memefolder
//
//  Created by Elliot Fiske on 1/3/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import UIKit
import YoutubeDL
import PMKAlamofire
import PromiseKit

class ViewController: UIViewController {
    
    @IBOutlet weak var twitterEntryText: UITextField!
    
    @IBAction func buttonPushed(_ sender: Any) {
        twitterEntryText?.resignFirstResponder()
        
        firstly { () -> Promise<Data> in
            TwitterDL.sharedInstance.getThumbnailData(forTweetURL: twitterEntryText.text ?? "")
        }
        .done { data in
            self.thumbnailDisplay?.image = UIImage(data: data)
        }
        .catch { error in
            switch error {
            case let error as TwitterAPIError:
                print("Some issue with the Twitter API :( \(error.localizedDescription)")
            default:
                print("Some other kind of error: \(error.localizedDescription)")
            }
        }
    }
    
    @IBOutlet weak var thumbnailDisplay: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

