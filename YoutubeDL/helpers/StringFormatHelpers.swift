//
//  StringFormatHelpers.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 2/11/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import CoreGraphics

public func durationText(seconds: Int) -> String {
    let minutesComponent = Int(seconds / 60)
    let secondsComponent = Int(seconds % 60)

    return String(format: "%01i:%02i", minutesComponent, secondsComponent)
}
