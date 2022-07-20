// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let twitterAPIType = try? newJSONDecoder().decode(TwitterAPIType.self, from: jsonData)

import Foundation

// MARK: - TwitterAPIType
public struct TwitterAPIType: Codable {
    public let createdAt: String?
    public let id: Double?
    public let idStr, fullText: String?
    public let truncated: Bool?
    public let displayTextRange: [Int]?
    public let entities: Entities?
    public let extendedEntities: ExtendedEntities?
    public let source: String?
    public let inReplyToStatusID, inReplyToStatusIDStr, inReplyToUserID, inReplyToUserIDStr: JSONNull?
    public let inReplyToScreenName: JSONNull?
    public let user: User?
    public let geo, coordinates, place, contributors: JSONNull?
    public let isQuoteStatus: Bool?
    public let retweetCount, favoriteCount, replyCount: Int?
    public let favorited, retweeted, possiblySensitive, possiblySensitiveAppealable: Bool?
    public let possiblySensitiveEditable: Bool?
    public let lang: String?
    public let supplementalLanguage: JSONNull?
    public let selfThread: SelfThread?

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case id
        case idStr = "id_str"
        case fullText = "full_text"
        case truncated
        case displayTextRange = "display_text_range"
        case entities
        case extendedEntities = "extended_entities"
        case source
        case inReplyToStatusID = "in_reply_to_status_id"
        case inReplyToStatusIDStr = "in_reply_to_status_id_str"
        case inReplyToUserID = "in_reply_to_user_id"
        case inReplyToUserIDStr = "in_reply_to_user_id_str"
        case inReplyToScreenName = "in_reply_to_screen_name"
        case user, geo, coordinates, place, contributors
        case isQuoteStatus = "is_quote_status"
        case retweetCount = "retweet_count"
        case favoriteCount = "favorite_count"
        case replyCount = "reply_count"
        case favorited, retweeted
        case possiblySensitive = "possibly_sensitive"
        case possiblySensitiveAppealable = "possibly_sensitive_appealable"
        case possiblySensitiveEditable = "possibly_sensitive_editable"
        case lang
        case supplementalLanguage = "supplemental_language"
        case selfThread = "self_thread"
    }

    public init(createdAt: String?, id: Double?, idStr: String?, fullText: String?, truncated: Bool?, displayTextRange: [Int]?, entities: Entities?, extendedEntities: ExtendedEntities?, source: String?, inReplyToStatusID: JSONNull?, inReplyToStatusIDStr: JSONNull?, inReplyToUserID: JSONNull?, inReplyToUserIDStr: JSONNull?, inReplyToScreenName: JSONNull?, user: User?, geo: JSONNull?, coordinates: JSONNull?, place: JSONNull?, contributors: JSONNull?, isQuoteStatus: Bool?, retweetCount: Int?, favoriteCount: Int?, replyCount: Int?, favorited: Bool?, retweeted: Bool?, possiblySensitive: Bool?, possiblySensitiveAppealable: Bool?, possiblySensitiveEditable: Bool?, lang: String?, supplementalLanguage: JSONNull?, selfThread: SelfThread?) {
        self.createdAt = createdAt
        self.id = id
        self.idStr = idStr
        self.fullText = fullText
        self.truncated = truncated
        self.displayTextRange = displayTextRange
        self.entities = entities
        self.extendedEntities = extendedEntities
        self.source = source
        self.inReplyToStatusID = inReplyToStatusID
        self.inReplyToStatusIDStr = inReplyToStatusIDStr
        self.inReplyToUserID = inReplyToUserID
        self.inReplyToUserIDStr = inReplyToUserIDStr
        self.inReplyToScreenName = inReplyToScreenName
        self.user = user
        self.geo = geo
        self.coordinates = coordinates
        self.place = place
        self.contributors = contributors
        self.isQuoteStatus = isQuoteStatus
        self.retweetCount = retweetCount
        self.favoriteCount = favoriteCount
        self.replyCount = replyCount
        self.favorited = favorited
        self.retweeted = retweeted
        self.possiblySensitive = possiblySensitive
        self.possiblySensitiveAppealable = possiblySensitiveAppealable
        self.possiblySensitiveEditable = possiblySensitiveEditable
        self.lang = lang
        self.supplementalLanguage = supplementalLanguage
        self.selfThread = selfThread
    }
}

// MARK: - Entities
public struct Entities: Codable {
    public let hashtags, symbols, userMentions, urls: [JSONAny]?
    public let media: [Media]?

    enum CodingKeys: String, CodingKey {
        case hashtags, symbols
        case userMentions = "user_mentions"
        case urls, media
    }

    public init(hashtags: [JSONAny]?, symbols: [JSONAny]?, userMentions: [JSONAny]?, urls: [JSONAny]?, media: [Media]?) {
        self.hashtags = hashtags
        self.symbols = symbols
        self.userMentions = userMentions
        self.urls = urls
        self.media = media
    }
}

// MARK: - Media
public struct Media: Codable {
    public let id: Double?
    public let idStr: String?
    public let indices: [Int]?
    public let mediaURL: String?
    public let mediaURLHTTPS: String?
    public let url: String?
    public let displayURL: String?
    public let expandedURL: String?
    public let type: String?
    public let originalInfo: OriginalInfo?
    public let sizes: Sizes?
    public let videoInfo: VideoInfo?
    public let mediaKey: String?
    public let additionalMediaInfo: AdditionalMediaInfo?

    enum CodingKeys: String, CodingKey {
        case id
        case idStr = "id_str"
        case indices
        case mediaURL = "media_url"
        case mediaURLHTTPS = "media_url_https"
        case url
        case displayURL = "display_url"
        case expandedURL = "expanded_url"
        case type
        case originalInfo = "original_info"
        case sizes
        case videoInfo = "video_info"
        case mediaKey = "media_key"
        case additionalMediaInfo = "additional_media_info"
    }

    public init(id: Double?, idStr: String?, indices: [Int]?, mediaURL: String?, mediaURLHTTPS: String?, url: String?, displayURL: String?, expandedURL: String?, type: String?, originalInfo: OriginalInfo?, sizes: Sizes?, videoInfo: VideoInfo?, mediaKey: String?, additionalMediaInfo: AdditionalMediaInfo?) {
        self.id = id
        self.idStr = idStr
        self.indices = indices
        self.mediaURL = mediaURL
        self.mediaURLHTTPS = mediaURLHTTPS
        self.url = url
        self.displayURL = displayURL
        self.expandedURL = expandedURL
        self.type = type
        self.originalInfo = originalInfo
        self.sizes = sizes
        self.videoInfo = videoInfo
        self.mediaKey = mediaKey
        self.additionalMediaInfo = additionalMediaInfo
    }
}

// MARK: - AdditionalMediaInfo
public struct AdditionalMediaInfo: Codable {
    public let monetizable: Bool?

    public init(monetizable: Bool?) {
        self.monetizable = monetizable
    }
}

// MARK: - OriginalInfo
public struct OriginalInfo: Codable {
    public let width, height: Int?

    public init(width: Int?, height: Int?) {
        self.width = width
        self.height = height
    }
}

// MARK: - Sizes
public struct Sizes: Codable {
    public let thumb, medium, small, large: Large?

    public init(thumb: Large?, medium: Large?, small: Large?, large: Large?) {
        self.thumb = thumb
        self.medium = medium
        self.small = small
        self.large = large
    }
}

// MARK: - Large
public struct Large: Codable {
    public let w, h: Int?
    public let resize: String?

    public init(w: Int?, h: Int?, resize: String?) {
        self.w = w
        self.h = h
        self.resize = resize
    }
}

// MARK: - VideoInfo
public struct VideoInfo: Codable {
    public let aspectRatio: [Int]?
    public let durationMillis: Int?
    public let variants: [Variant]?

    enum CodingKeys: String, CodingKey {
        case aspectRatio = "aspect_ratio"
        case durationMillis = "duration_millis"
        case variants
    }

    public init(aspectRatio: [Int]?, durationMillis: Int?, variants: [Variant]?) {
        self.aspectRatio = aspectRatio
        self.durationMillis = durationMillis
        self.variants = variants
    }
}

// MARK: - Variant
public struct Variant: Codable {
    public let bitrate: Int?
    public let contentType: String?
    public let url: String?

    enum CodingKeys: String, CodingKey {
        case bitrate
        case contentType = "content_type"
        case url
    }

    public init(bitrate: Int?, contentType: String?, url: String?) {
        self.bitrate = bitrate
        self.contentType = contentType
        self.url = url
    }
}

// MARK: - ExtendedEntities
public struct ExtendedEntities: Codable {
    public let media: [Media]?

    public init(media: [Media]?) {
        self.media = media
    }
}

// MARK: - SelfThread
public struct SelfThread: Codable {
    public let id: Double?
    public let idStr: String?

    enum CodingKeys: String, CodingKey {
        case id
        case idStr = "id_str"
    }

    public init(id: Double?, idStr: String?) {
        self.id = id
        self.idStr = idStr
    }
}

// MARK: - User
public struct User: Codable {
    public let id: Int?
    public let idStr, name, screenName, location: String?
    public let url: String?
    public let userDescription: String?
    public let protected: Bool?
    public let followersCount, friendsCount, listedCount: Int?
    public let createdAt: String?
    public let favouritesCount: Int?
    public let utcOffset, timeZone: JSONNull?
    public let geoEnabled, verified: Bool?
    public let statusesCount, mediaCount: Int?
    public let lang: JSONNull?
    public let contributorsEnabled, isTranslator, isTranslationEnabled: Bool?
    public let profileBackgroundColor: String?
    public let profileBackgroundImageURL: String?
    public let profileBackgroundImageURLHTTPS: String?
    public let profileBackgroundTile: Bool?
    public let profileImageURL: String?
    public let profileImageURLHTTPS: String?
    public let profileBannerURL: String?
    public let profileLinkColor, profileSidebarBorderColor, profileSidebarFillColor, profileTextColor: String?
    public let profileUseBackgroundImage, hasExtendedProfile, defaultProfile, defaultProfileImage: Bool?
    public let hasCustomTimelines: Bool?
    public let following, followRequestSent, notifications: JSONNull?
    public let businessProfileState, translatorType: String?
    public let withheldInCountries: [JSONAny]?
    public let requireSomeConsent: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case idStr = "id_str"
        case name
        case screenName = "screen_name"
        case location, url
        case userDescription = "description"
        case protected
        case followersCount = "followers_count"
        case friendsCount = "friends_count"
        case listedCount = "listed_count"
        case createdAt = "created_at"
        case favouritesCount = "favourites_count"
        case utcOffset = "utc_offset"
        case timeZone = "time_zone"
        case geoEnabled = "geo_enabled"
        case verified
        case statusesCount = "statuses_count"
        case mediaCount = "media_count"
        case lang
        case contributorsEnabled = "contributors_enabled"
        case isTranslator = "is_translator"
        case isTranslationEnabled = "is_translation_enabled"
        case profileBackgroundColor = "profile_background_color"
        case profileBackgroundImageURL = "profile_background_image_url"
        case profileBackgroundImageURLHTTPS = "profile_background_image_url_https"
        case profileBackgroundTile = "profile_background_tile"
        case profileImageURL = "profile_image_url"
        case profileImageURLHTTPS = "profile_image_url_https"
        case profileBannerURL = "profile_banner_url"
        case profileLinkColor = "profile_link_color"
        case profileSidebarBorderColor = "profile_sidebar_border_color"
        case profileSidebarFillColor = "profile_sidebar_fill_color"
        case profileTextColor = "profile_text_color"
        case profileUseBackgroundImage = "profile_use_background_image"
        case hasExtendedProfile = "has_extended_profile"
        case defaultProfile = "default_profile"
        case defaultProfileImage = "default_profile_image"
        case hasCustomTimelines = "has_custom_timelines"
        case following
        case followRequestSent = "follow_request_sent"
        case notifications
        case businessProfileState = "business_profile_state"
        case translatorType = "translator_type"
        case withheldInCountries = "withheld_in_countries"
        case requireSomeConsent = "require_some_consent"
    }

    public init(id: Int?, idStr: String?, name: String?, screenName: String?, location: String?, url: String?, userDescription: String?, protected: Bool?, followersCount: Int?, friendsCount: Int?, listedCount: Int?, createdAt: String?, favouritesCount: Int?, utcOffset: JSONNull?, timeZone: JSONNull?, geoEnabled: Bool?, verified: Bool?, statusesCount: Int?, mediaCount: Int?, lang: JSONNull?, contributorsEnabled: Bool?, isTranslator: Bool?, isTranslationEnabled: Bool?, profileBackgroundColor: String?, profileBackgroundImageURL: String?, profileBackgroundImageURLHTTPS: String?, profileBackgroundTile: Bool?, profileImageURL: String?, profileImageURLHTTPS: String?, profileBannerURL: String?, profileLinkColor: String?, profileSidebarBorderColor: String?, profileSidebarFillColor: String?, profileTextColor: String?, profileUseBackgroundImage: Bool?, hasExtendedProfile: Bool?, defaultProfile: Bool?, defaultProfileImage: Bool?, hasCustomTimelines: Bool?, following: JSONNull?, followRequestSent: JSONNull?, notifications: JSONNull?, businessProfileState: String?, translatorType: String?, withheldInCountries: [JSONAny]?, requireSomeConsent: Bool?) {
        self.id = id
        self.idStr = idStr
        self.name = name
        self.screenName = screenName
        self.location = location
        self.url = url
        self.userDescription = userDescription
        self.protected = protected
        self.followersCount = followersCount
        self.friendsCount = friendsCount
        self.listedCount = listedCount
        self.createdAt = createdAt
        self.favouritesCount = favouritesCount
        self.utcOffset = utcOffset
        self.timeZone = timeZone
        self.geoEnabled = geoEnabled
        self.verified = verified
        self.statusesCount = statusesCount
        self.mediaCount = mediaCount
        self.lang = lang
        self.contributorsEnabled = contributorsEnabled
        self.isTranslator = isTranslator
        self.isTranslationEnabled = isTranslationEnabled
        self.profileBackgroundColor = profileBackgroundColor
        self.profileBackgroundImageURL = profileBackgroundImageURL
        self.profileBackgroundImageURLHTTPS = profileBackgroundImageURLHTTPS
        self.profileBackgroundTile = profileBackgroundTile
        self.profileImageURL = profileImageURL
        self.profileImageURLHTTPS = profileImageURLHTTPS
        self.profileBannerURL = profileBannerURL
        self.profileLinkColor = profileLinkColor
        self.profileSidebarBorderColor = profileSidebarBorderColor
        self.profileSidebarFillColor = profileSidebarFillColor
        self.profileTextColor = profileTextColor
        self.profileUseBackgroundImage = profileUseBackgroundImage
        self.hasExtendedProfile = hasExtendedProfile
        self.defaultProfile = defaultProfile
        self.defaultProfileImage = defaultProfileImage
        self.hasCustomTimelines = hasCustomTimelines
        self.following = following
        self.followRequestSent = followRequestSent
        self.notifications = notifications
        self.businessProfileState = businessProfileState
        self.translatorType = translatorType
        self.withheldInCountries = withheldInCountries
        self.requireSomeConsent = requireSomeConsent
    }
}

// MARK: - Encode/decode helpers

public class JSONNull: Codable, Hashable {

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

class JSONCodingKey: CodingKey {
    let key: String

    required init?(intValue: Int) {
        return nil
    }

    required init?(stringValue: String) {
        key = stringValue
    }

    var intValue: Int? {
        return nil
    }

    var stringValue: String {
        return key
    }
}

public class JSONAny: Codable {

    public let value: Any

    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }

    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }

    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }

    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }

    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }

    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            self.value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try JSONAny.decode(from: container)
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: self.value)
        }
    }
}
