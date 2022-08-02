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

public class FilesizeButton: UIView, NibLoadable {
    @IBOutlet weak var dimensions: UILabel!
    @IBOutlet weak var filesize: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet var press: UILongPressGestureRecognizer!
    
    lazy var pressed: Observable<Void> = {
        return press.rx.event.compactMap {
            if ($0.state == .ended) {
                return ()
            }
            return nil
        }
    }()
    
    func commonInit() {
        
        
        press.rx.event.compactMap {
            switch ($0.state) {
            case .began, .possible:
                return UIColor.systemGray2
            case .cancelled, .failed, .ended:
                return UIColor.systemGray3
            default:
                return nil
            }
        }
            .bind(to: backgroundView.rx.backgroundColor)
            .disposed(by: rx.disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }
}
