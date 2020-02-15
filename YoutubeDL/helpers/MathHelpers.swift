//
//  MathHelpers.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 2/11/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import Foundation

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

extension Strideable where Stride: SignedInteger {
    func clamped(to limits: CountableClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
