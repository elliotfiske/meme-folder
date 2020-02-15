// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let twitterStatus = try? newJSONDecoder().decode(TwitterStatus.self, from: jsonData)
//
// https://app.quicktype.io?share=Shypfot5lnSSTknpSzyD

import Foundation

// MARK: - TwitterStatus
struct TwitterStatus: Codable {
    let idStr, fullText: String
    let entities: Entities
    let extendedEntities: ExtendedEntities
    let user: User
    let favoriteCount, replyCount: Int
    let lang: String
    let supplementalLanguage: JSONNull?

    enum CodingKeys: String, CodingKey {
        case idStr = "id_str"
        case fullText = "full_text"
        case entities
        case extendedEntities = "extended_entities"
        case user
        case favoriteCount = "favorite_count"
        case replyCount = "reply_count"
        case lang
        case supplementalLanguage = "supplemental_language"
    }
}

// MARK: - Entities
struct Entities: Codable {
    let media: [EntitiesMedia]
}

// MARK: - EntitiesMedia
struct EntitiesMedia: Codable {
    let mediaURLHTTPS: String
    let type: String
    let originalInfo: OriginalInfo
    let sizes: Sizes

    enum CodingKeys: String, CodingKey {
        case mediaURLHTTPS = "media_url_https"
        case type
        case originalInfo = "original_info"
        case sizes
    }
}

// MARK: - OriginalInfo
struct OriginalInfo: Codable {
    let width, height: Int
}

// MARK: - Sizes
struct Sizes: Codable {
    let medium, large, small, thumb: Large
}

// MARK: - Large
struct Large: Codable {
    let w, h: Int
    let resize: String
}

// MARK: - ExtendedEntities
struct ExtendedEntities: Codable {
    let media: [ExtendedEntitiesMedia]
}

// MARK: - ExtendedEntitiesMedia
struct ExtendedEntitiesMedia: Codable {
    let mediaURLHTTPS: String
    let type: String

    enum CodingKeys: String, CodingKey {
        case mediaURLHTTPS = "media_url_https"
        case type
    }
}

// MARK: - User
struct User: Codable {
    let id: Double
    let idStr, name, screenName: String
    let verified: Bool
    let statusesCount, mediaCount: Int
    let lang: JSONNull?

    enum CodingKeys: String, CodingKey {
        case id
        case idStr = "id_str"
        case name
        case screenName = "screen_name"
        case verified
        case statusesCount = "statuses_count"
        case mediaCount = "media_count"
        case lang
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public func hash(into hasher: inout Hasher) {
        // No-op
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
