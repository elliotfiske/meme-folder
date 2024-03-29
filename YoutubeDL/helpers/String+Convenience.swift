//
//  String+Convenience.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 1/5/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import Foundation

extension String {
   
   //
   // Usage:
   //
   // let res = "1my 2own 3string".groups(for:"(([0-9]+)[a-z]+) ")
   //
   func groups(for regexPattern: String) -> [[String]] {
      do {
         let text = self
         let regex = try NSRegularExpression(pattern: regexPattern)
         let matches = regex.matches(in: text,
                                     range: NSRange(text.startIndex..., in: text))
         return matches.map { match in
            return (0..<match.numberOfRanges).map {
               let rangeBounds = match.range(at: $0)
               guard let range = Range(rangeBounds, in: text) else {
                  return ""
               }
               return String(text[range])
            }
         }
      } catch let error {
         print("invalid regex: \(error.localizedDescription)")
         return []
      }
   }
}
