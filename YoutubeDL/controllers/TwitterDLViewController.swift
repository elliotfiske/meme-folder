//
//  ViewController.swift
//  memefolder
//
//  Created by Elliot Fiske on 1/3/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import UIKit
import PMKAlamofire
import PromiseKit

public class TwitterDLViewController: UIViewController {
    
    @IBOutlet weak var twitterEntryText: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageLoadingActivityIndicator: UIActivityIndicatorView!
    
    @IBAction func buttonPushed(_ sender: Any) {
        guard !(twitterEntryText.text?.isEmpty ?? false) else {
            showInputError(for: TwitterAPIError.emptyInput)
            return
        }

        twitterEntryText?.resignFirstResponder()
        
        firstly {
            try TwitterAPI.sharedInstance.getMediaURLs(usingTweetURL: twitterEntryText.text ?? "")
        }
        .then { (thumbnailURL: String, videoURL: String?) -> Promise<(data: Data, response: PMKAlamofireDataResponse)>  in
            return Alamofire.request(thumbnailURL)
                .validate()
                .responseData()
        }
        .done { data, _ in
            self.thumbnailDisplay?.image = UIImage(data: data)
        }
        .ensure { [weak self] in
            self?.imageLoadingActivityIndicator.stopAnimating()
        }
        .catch { error in
            switch error {
            case let error as TwitterAPIError:
                print("Some issue with the Twitter API :( \(error)")
                self.showInputError(for: error)
            default:
                print("Some other kind of error: \(error.localizedDescription)")
            }
        }
        
        imageLoadingActivityIndicator.startAnimating()
    }
    
    @IBOutlet weak var thumbnailDisplay: UIImageView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        twitterEntryText.delegate = self
    }
}

extension TwitterDLViewController: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        hideInputError()
        return true
    }
}
