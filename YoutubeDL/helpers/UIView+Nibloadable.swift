//
//  UIView+Nibloadable.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 1/30/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import Foundation
import UIKit

///
/// Adopting 'NibLoadable' makes it possible to have NIBs INSIDE
///      of other NIBs, and preview the whole thing in Interface Builder.
///
/// `nibName` defaults to the name of your UIView's class, so be sure to change
///      it if it's different.
///
/// See details and caveats here: https://stackoverflow.com/a/47295926/3880742
///
/// It's also availble at {SOURCE_ROOT}/saved_online_docs/StackOverflowNibLoadableDetails.png
///      if that link goes down.
///
public protocol NibLoadable {
    static var nibName: String { get }
}

public extension NibLoadable where Self: UIView {

    static var nibName: String {
        return String(describing: Self.self) // defaults to the name of the class implementing this protocol.
    }

    static var nib: UINib {
        let bundle = Bundle(for: Self.self)
        return UINib(nibName: Self.nibName, bundle: bundle)
    }

    func setupFromNib() {
        guard let view = Self.nib.instantiate(withOwner: self, options: nil).first as? UIView else { fatalError("Error loading \(self) from nib") }
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
}