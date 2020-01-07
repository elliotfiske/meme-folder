//
//  ViewController+Errors.swift
//  memefolder
//
//  Created by Max Linsenbard on 1/6/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import UIKit

public enum TwitterAPIError: Error {
   case invalidToken(String)
   case invalidInput(String)
   case emptyInput

   public var message: String {
      switch self {
      case .invalidToken(let message):
         return message
      case .invalidInput(let message):
         return message
      case .emptyInput:
         return "Oops, looks like you didn't type anything."
      }
   }

   public var color: UIColor {
      return .systemRed
   }
}
