//
//  ViewController+Errors.swift
//  memefolder
//
//  Created by Max Linsenbard on 1/6/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import UIKit
import SwiftyJSON

public enum TwitterAPIError: Error {
    
    case invalidToken(String)
    case invalidInput(String)
    case unexpectedDataShape(String)  // Twitter API gave us back something we didn't expect
    case emptyInput
    case tweetHasNoMedia
    
    public var message: String {
        switch self {
        case .invalidToken(let message):
            return "Couldn't authorize with Twitter: \(message)"
        case .invalidInput(let message):
            return message
        case .unexpectedDataShape(let message):
            return message
        case .emptyInput:
            return "Oops, looks like you didn't type anything."
        case .tweetHasNoMedia:
            return "Looks like that tweet has no media."
        }
    }
    
    public var color: UIColor {
        return .systemRed
    }
}

// TODO: Parse out internet errors like 404, rate limit etc.
//          into more helpful stuff here
public enum InternetError: Error {
    case unparsableJSON(String)
    case badlyStructuredJSON(String)
}

public class PhotoRetrievalError: Error {
    var message: String
    
    init(message: String) {
        self.message = message
    }
}

//
// Helper method: Swift's default JSON decoder throws an unhelpful
//    "NSError" instead of a nice usable Error type.
//
public func parseJSON(data: Data) throws -> JSON {
    do {
        return try JSON(data: data)
    } catch {
        let badJSON = String(data: data, encoding: .utf8)
        throw InternetError.unparsableJSON(badJSON ?? "Couldn't parse data to String: \(data)")
    }
}

