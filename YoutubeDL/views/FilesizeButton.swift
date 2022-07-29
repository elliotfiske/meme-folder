//
//  FilesizeButton.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 7/23/22.
//  Copyright © 2022 Meme Folder. All rights reserved.
//

import Foundation
import UIKit

public class FilesizeButton: UIView, NibLoadable {
    @IBOutlet weak var dimensions: UILabel!
    @IBOutlet weak var filesize: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }
}
