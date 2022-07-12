// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let twitterAPIType = try? newJSONDecoder().decode(TwitterAPIType.self, from: jsonData)

import Foundation

// MARK: - TwitterAPIType
public struct TwitterAPIType: Codable {
    let idStr: String
    let entities, extendedEntities: Entities
    let user: User
    let possiblySensitive: Bool?
    let lang: String?

    enum CodingKeys: String, CodingKey {
        case idStr = "id_str"
        case entities
        case extendedEntities = "extended_entities"
        case user
        case possiblySensitive = "possibly_sensitive"
        case lang
    }
}

// MARK: - Entities
struct Entities: Codable {
    let media: [Media]
}

// MARK: - Media
struct Media: Codable {
    let idStr: String
    let mediaURLHTTPS: String
    let type: String
    let originalInfo: OriginalInfo
    let sizes: Sizes
    let videoInfo: VideoInfo?

    enum CodingKeys: String, CodingKey {
        case idStr = "id_str"
        case mediaURLHTTPS = "media_url_https"
        case type
        case originalInfo = "original_info"
        case sizes
        case videoInfo = "video_info"
    }
}

// MARK: - OriginalInfo
struct OriginalInfo: Codable {
    let width, height: Int
    let focusRects: [FocusRect]?

    enum CodingKeys: String, CodingKey {
        case width, height
        case focusRects = "focus_rects"
    }
}

// MARK: - FocusRect
struct FocusRect: Codable {
    let x, y, h, w: Int
}

// MARK: - Sizes
struct Sizes: Codable {
    let thumb, medium, small, large: Large
}

// MARK: - Large
struct Large: Codable {
    let w, h: Int
    let resize: Resize
}

enum Resize: String, Codable {
    case crop = "crop"
    case fit = "fit"
}

// MARK: - VideoInfo
struct VideoInfo: Codable {
    let aspectRatio: [Int]
    let durationMillis: Int
    let variants: [Variant]

    enum CodingKeys: String, CodingKey {
        case aspectRatio = "aspect_ratio"
        case durationMillis = "duration_millis"
        case variants
    }
}

// MARK: - Variant
struct Variant: Codable {
    let contentType: String
    let url: String
    let bitrate: Int?

    enum CodingKeys: String, CodingKey {
        case contentType = "content_type"
        case url, bitrate
    }
}

// MARK: - User
struct User: Codable {
    let idStr, name, screenName: String
    let protected: Bool

    enum CodingKeys: String, CodingKey {
        case idStr = "id_str"
        case name
        case screenName = "screen_name"
        case protected
    }
}
