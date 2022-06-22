//
//  ImageCell.swift
//  memefolder
//
//  Created by Elliot Fiske on 2/9/21.
//  Copyright © 2021 Meme Folder. All rights reserved.
//

import UIKit
import RxSwift

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var assetIdentifier: String = ""
    
    // Dispose bag that disposes when this cell is reused.
    var reuseDisposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Clears the dispose bag by instantiating a new one.
        reuseDisposeBag = DisposeBag()
    }
}
