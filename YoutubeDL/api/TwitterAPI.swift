//
//  TwitterDownloader.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 1/4/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import Foundation
import PromiseKit
import PMKAlamofire
import SwiftyJSON

public class TwitterAPI {
    
    public enum MediaResultURLs {
        /// 1-4 images in a tweet
        case images(urls: [String])
        
        /// Videos can have multiple URLs, for the different qualities.
        case videos(thumbnail: String, urls: [String])
    }
    
    public static let sharedInstance: TwitterAPI = TwitterAPI()
    
    // yoinked from YoutubeDL's repo :3
    static let BEARER_TOKEN = "Bearer AAAAAAAAAAAAAAAAAAAAAPYXBAAAAAAACLXUNDekMxqa8h%2F40K4moUkGsoc%3DTYfbDKbT3jJPCEVnMYqilB28NHfOPqkca3qaAxGfsyKCs0wRbw"
    static let BASE_API = "https://api.twitter.com/1.1/"
    
    static let BASE_HEADERS: HTTPHeaders = [
        "Authorization" : TwitterAPI.BEARER_TOKEN,
        "Accept" : "application/json"
    ]
    
    // MARK: Public functions
    
    // Elliot's note: This will eventually move to the server side, so we can
    //    justify selling a subscription. For now just kinda practicing API
    //    calls and data manipulation with Swift.
    public func getMediaURLs(usingTweetURL url: String) throws -> Promise<MediaResultURLs> {
        let matchedGroups = url.groups(for: #"https?://(?:(?:www|m(?:obile)?)\.)?twitter\.com/(?:(?:i/web|[^\/]+)/status|statuses)/(?<id>\d+)"#)
        
        guard let splitURL = matchedGroups.get(index: 0),
            let tweetID = splitURL.get(index: 1) else {
                // TODO-EF: Send a non-fatal to Firebase
                print("Couldn't find tweet ID from URL...")
                throw TwitterAPIError.invalidInput("Invalid Twitter URL: \(url)")
        }
        
        return firstly { () -> Promise<Data> in
            let params = [
                "cards_platform" : "Web-12",
                "include_cards" : "1",
                "include_reply_count" : "1",
                "include_user_entities" : "0",
                "tweet_mode" : "extended"
            ]
            
            return callAPI(endpoint: "statuses/show/\(tweetID).json", parameters: params)
        }
        .map { data in
            let twitterStatus = try JSONDecoder().decode(TwitterAPIType.self, from: data)
            
            let mediaArray = twitterStatus.extendedEntities.media
            
            guard mediaArray.count > 0 else {
                throw TwitterAPIError.tweetHasNoMedia
            }
            
            let mediaType = mediaArray[0].type
            
            if mediaType == "video" {
                return try self.parseVideoInfo(media: mediaArray[0])
            } else if mediaType == "image" {
                return .images(urls: [])    // TODO: This
            } else {
                fatalError("AHHHH")
            }
        }
    }
    
    // MARK: Twitter API helper functions
    
    ///
    /// Given the media content of a tweet with type == "video", parse out the
    ///     thumbnail and the video variant URLs.
    ///
    func parseVideoInfo(media: Media) throws -> MediaResultURLs {
        var variants = media.videoInfo!.variants
        
        variants = variants.filter {
            variant in
            return variant.contentType == "video/mp4"
        }
        
        let variantURLs = variants.map {
            variant in
            variant.url
        }
        
        return .videos(thumbnail: media.mediaURLHTTPS, urls: variantURLs)
    }
    
    // We will need this guest token to access Twitter as a guest, until
    //    Twitter approves my developer account
    var cachedGuestToken: String?
    func getGuestToken() -> Promise<String> {
        if let cachedGuestToken = cachedGuestToken {
            return Promise.value(cachedGuestToken)
        }
        
        return firstly {
            Alamofire.request(TwitterAPI.BASE_API + "guest/activate.json",
                              method: .post,
                              headers: TwitterAPI.BASE_HEADERS)
                .responseData()
        }
        .map { data, _ -> String in
            let json = try parseJSON(data: data)
            
            guard let token = json["guest_token"].string else {
                throw TwitterAPIError.invalidToken("No token found in response: \(json.stringValue)")
            }
            
            return token
        }
    }
    
    //
    // Call the Twitter API with the given endpoint, method, params and headers.
    //
    // Uses the cached guest token, or tries to fetch a new one.
    //
    func callAPI(endpoint: String, method: HTTPMethod = .get, parameters: Parameters = [:], headers: HTTPHeaders? = nil) -> Promise<Data> {
        
        return firstly { () -> Promise<String> in
            getGuestToken()
        }
        .then { token -> Promise<(data: Data, response: PMKAlamofireDataResponse)> in
            var combinedHeaders = TwitterAPI.BASE_HEADERS.merging(headers ?? [:],
                                                                  uniquingKeysWith: { (_, new) in new })
            combinedHeaders["x-guest-token"] = token
            
            return Alamofire.request(TwitterAPI.BASE_API + endpoint, method: method, parameters: parameters, headers: combinedHeaders)
                .validate()
                .responseData()
        }
        .map { data, _ in
            return data
        }
    }
}
