//
//  SegmentHeader.swift
//  memefolder
//
//  Created by Elliot Fiske on 2/24/21.
//  Copyright © 2021 Meme Folder. All rights reserved.
//

import UIKit
import YoutubeDL

@IBDesignable
public class SegmentHeader: UIView, NibLoadable {
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    func commonInit() {
        // Fill me up!!
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
        commonInit()
    }
}
