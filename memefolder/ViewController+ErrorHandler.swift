//
//  ViewController+ErrorHandler.swift
//  memefolder
//
//  Created by Max Linsenbard on 1/6/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import UIKit
import YoutubeDL

extension ViewController {
    func showInputError(for error: TwitterAPIError) {
        errorLabel.text = error.message
        errorLabel.textColor = error.color

        if errorLabel.isHidden {
            view.sendSubviewToBack(errorLabel)

            // Animate the error label to pop up from behind TextView and fade in.
            errorLabelBottomConstraint.constant = 8
            errorLabel.alpha = 0
            errorLabel.isHidden = false

            UIView.animateKeyframes(withDuration: 0.32, delay: 0, options: [], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.32) { [weak self] in
                    self?.errorLabel.alpha = 1
                    self?.errorLabel.setNeedsLayout()
                }
            })
        }
    }

    func hideInputError() {
        guard !errorLabel.isHidden else { return }
        errorLabelBottomConstraint.constant = -20

        UIView.animate(withDuration: 0.24, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            self?.errorLabel.alpha = 0
            self?.errorLabel.setNeedsLayout()
        }) { [weak self] complete in
            if complete {
                self?.errorLabel.isHidden = true
            }
        }
    }
}
