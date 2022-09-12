//
//  ExampleButton.swift
//  memefolder
//
//  Created by Elliot Fiske on 9/9/22.
//  Copyright © 2022 Meme Folder. All rights reserved.
//

import YoutubeDL
import Foundation
import UIKit
import RxSwift

@IBDesignable
class ExampleButton: UIView, NibLoadable, UIGestureRecognizerDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var exampleGifName: UILabel!
    let pan = UIPanGestureRecognizer()
    let tap = UILongPressGestureRecognizer()
    
    public var myImage: UIImage? {
        didSet {
            guard let image = myImage else { return }
            imagePreview.image = image
        }
    }
    
    public var myText: String? {
        didSet {
            guard let text = myText else {return}
            label.text = text
        }
    }

    lazy var pressed: Observable<Void> = {
        return tap.rx.event.compactMap {
            [weak self] in
            guard let self = self else { return nil }
            if $0.state == .ended, self.backgroundView.bounds.contains($0.location(in: self.backgroundView)) {
                print("Pressed, my friend!")
                return ()
            }
            return nil
        }
    }()

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }

    func commonInit() {
        backgroundView.addGestureRecognizer(pan)
        backgroundView.addGestureRecognizer(tap)

        pan.delegate = self
        tap.delegate = self

        tap.minimumPressDuration = 0.0

        let anyTouch = Observable<UIGestureRecognizer>.merge(
            tap.rx.event.map { $0 as UIGestureRecognizer },
            pan.rx.event.map { $0 as UIGestureRecognizer }
        )

        anyTouch.compactMap {
            [weak self] in
            switch ($0.state) {
                case .began, .possible:
                    return UIColor.systemGray2
                case .cancelled, .failed, .ended:
                    return UIColor.systemGray4
                case .changed:
                    guard let self = self else { return nil }
                    if self.backgroundView.bounds.contains($0.location(in: self.backgroundView)) {
                        return UIColor.systemGray2
                    }
                return UIColor.systemGray4
                default:
                    return nil
            }
        }
        .bind(to: backgroundView.rx.backgroundColor)
        .disposed(by: rx.disposeBag)
    }

    required init?(
        coder aDecoder: NSCoder
    ) {
        super.init(coder: aDecoder)
        setupFromNib()
        commonInit()
    }

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        setupFromNib()
        commonInit()
    }
}
