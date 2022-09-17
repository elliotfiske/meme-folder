//
//  FilesizeButton.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 7/23/22.
//  Copyright © 2022 Meme Folder. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

public enum FilesizeButtonState {
    case idle, loadingInfo, savingToCameraRoll, done, error(Error)
}

public class FilesizeButton: UIView, NibLoadable {
    @IBOutlet weak var dimensions: UILabel!
    @IBOutlet weak var filesize: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet var press: UILongPressGestureRecognizer!

    public var onPress: () -> Void = {}

    @IBAction func pressMe(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended && !isDisabled {
            onPress()
        }
    }

    public var isDisabled = false {
        didSet {
            if isDisabled {
                backgroundView.backgroundColor = .systemGray
            }
        }
    }

    public var status: FilesizeButtonState = .idle {
        didSet {
            switch status {
                case .done:
                    dimensions.isHidden = true
                    filesize.isHidden = true

                    statusLabel.isHidden = false
                    statusLabel.text = "Done!"
                case .savingToCameraRoll:
                    dimensions.isHidden = true
                    filesize.isHidden = true

                    statusLabel.isHidden = false
                    statusLabel.text = "Saving..."
                case .idle:
                    print("Idle!")
                case .loadingInfo:
                    dimensions.isHidden = true
                    filesize.isHidden = true

                    statusLabel.isHidden = false
                    statusLabel.text = "Loading..."
            case .error(let err):
                    dimensions.isHidden = true
                    filesize.isHidden = true

                    statusLabel.isHidden = false
                    statusLabel.text = "Retry"
                
                if let elliot = err as? ElliotError,
                   elliot.category == .photoLibraryAccessDenied {
                    statusLabel.text = "Please allow Photos access and retry!"
                }
            }
        }
    }

    //    lazy var pressed: Observable<Void> = {
    //        return press.rx.event.compactMap {
    //            if ($0.state == .ended) {
    //                return ()
    //            }
    //            return nil
    //        }
    //    }()
    deinit {
        print("FilesizeButton deinitted")
    }

    func commonInit() {
        press.rx.event.compactMap {
            [weak self] in
            let disabled = self?.isDisabled ?? false
            if disabled { return nil }

            switch ($0.state) {
                case .began, .possible:
                    return UIColor.systemGray2
                case .cancelled, .failed, .ended:
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
