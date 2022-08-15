//
//  Errors.swift
//  memefolder
//
//  Created by Max Linsenbard on 1/6/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//
import SwiftyJSON
import UIKit
public enum ErrorCategory: String {
    case networkError
    case unexpectedDataShape
    case tokenNeedsRefresh
    case invalidUserInput
    /// Stuff like "can't retrieve a photo for some reason"
    case iosError
    case generic
}

public class ElliotError: Error {
    internal init(
        localizedMessage: String,
        developerMessage: String = "No message provided!",
        category: ErrorCategory = .generic,
        userCanRetry: Bool = false
    ) {
        self.userMessage = localizedMessage
        self.userCanRetry = userCanRetry
        self.developerMessage = developerMessage
        self.category = category
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    var userMessage: String
    var userCanRetry: Bool = false
    var developerMessage: String
    var category: ErrorCategory
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
        let error = ElliotError(
            localizedMessage: "Error accessing Twitter.",
            developerMessage:
                "Couldn't parse this to JSON: \(badJSON ?? "couldn't even parse it to a UTF8 string!")",
            category: .unexpectedDataShape
        )
        throw error
    }
}
