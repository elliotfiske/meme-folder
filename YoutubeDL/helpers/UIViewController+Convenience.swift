//
//  UIViewController+Convenience.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 1/14/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    public static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            let bundle = Bundle(for: T.self)
            return T.init(nibName: String(describing: T.self), bundle: bundle)
        }

        return instantiateFromNib()
    }
}
