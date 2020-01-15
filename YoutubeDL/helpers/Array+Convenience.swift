//
//  Array+Convenience.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 1/5/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import Foundation

extension Array {
    // Safely lookup an index that might be out of bounds,
    // returning nil if it does not exist
    func get(index: Int) -> Element? {
        if 0 <= index && index < count {
            return self[index]
        } else {
            return nil
        }
    }
}
