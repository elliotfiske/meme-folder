//
//  ShareViewController+ErrorHandler.swift
//  memefolder
//
//  Created by Max Linsenbard on 1/6/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import UIKit

extension TwitterDLViewController {
    func showInputError(for error: ElliotError) {
        errorLabel.text = error.localizedDescription

        if errorLabel.isHidden {
            view.sendSubviewToBack(errorLabel)

            // Animate the error label to pop up from behind TextView and fade in.
            errorLabel.alpha = 0
            errorLabel.isHidden = false

            UIView.animateKeyframes(withDuration: 0.35, delay: 0, options: [], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.32) { [weak self] in
                    self?.errorLabel.alpha = 1
                }
            })
        }
    }

    func hideInputError() {
        guard !errorLabel.isHidden else { return }

        UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6, animations: { [weak self] in
                self?.errorLabel.alpha = 0
            })}, completion: { _ in
                self.errorLabel.isHidden = true
        })
    }
}
