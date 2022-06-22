//
//  AspectFitImageView.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 1/25/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//
//  This class constrains the UIImageView's aspect ratio to match its content.
//
//  See https://gist.github.com/algal/03e661630a6869c883d9d915d5ecccbc
//

import UIKit

public class AspectFitImageView : UIImageView {
    /// constraint to maintain same aspect ratio as the image
    private var aspectRatioConstraint: NSLayoutConstraint? = nil
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        self.setup()
    }
    
    public override init(frame:CGRect) {
        super.init(frame:frame)
        self.setup()
    }
    
    public override init(image: UIImage!) {
        super.init(image:image)
        self.setup()
    }
    
    public override init(image: UIImage!, highlightedImage: UIImage?) {
        super.init(image:image,highlightedImage:highlightedImage)
        self.setup()
    }
    
    override public var image: UIImage? {
        didSet {
            self.updateAspectRatioConstraint()
        }
    }
    
    private func setup() {
        self.updateAspectRatioConstraint()
    }
    
    /// Removes any pre-existing aspect ratio constraint, and adds a new one based on the current image
    private func updateAspectRatioConstraint() {
        // remove any existing aspect ratio constraint
        if let c = self.aspectRatioConstraint {
            self.removeConstraint(c)
        }
        self.aspectRatioConstraint = nil
        
        if let imageSize = image?.size, imageSize.height != 0
        {
            let aspectRatio = imageSize.width / imageSize.height
            let c = NSLayoutConstraint(item: self, attribute: .width,
                                       relatedBy: .equal,
                                       toItem: self, attribute: .height,
                                       multiplier: aspectRatio, constant: 0)

            c.priority = UILayoutPriority.required
            self.addConstraint(c)
            self.aspectRatioConstraint = c
        }
    }
}
