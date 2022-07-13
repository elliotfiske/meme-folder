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

import RxSwift
import RxRelay
import Get
import NSObject_Rx

public class TwitterAPI: APIClientDelegate, HasDisposeBag {
    
    public enum MediaResultURLs {
        /// 1-4 images in a tweet
        case images(urls: [String])
        
        /// Videos can have multiple URLs, for the different qualities.
        case videos(thumbnail: String, urls: [String])
    }
    
    public static let sharedInstance: TwitterAPI = TwitterAPI()
    
    static let BASE_API = "https://api.twitter.com/1.1/"
    static let BASE_HEADERS: HTTPHeaders = [
        // yoinked from YoutubeDL's repo :3 (remember to switch over to my own at some point)
        "Authorization" : "Bearer AAAAAAAAAAAAAAAAAAAAAPYXBAAAAAAACLXUNDekMxqa8h%2F40K4moUkGsoc%3DTYfbDKbT3jJPCEVnMYqilB28NHfOPqkca3qaAxGfsyKCs0wRbw",
        "Accept" : "application/json"
    ]
    
    let client = APIClient(baseURL: URL(string: "https://api.twitter.com/1.1/")) {
        // yoinked from YoutubeDL's repo :3 (remember to switch over to my own at some point)
        $0.sessionConfiguration.httpAdditionalHeaders = ["Authorization" : "Bearer AAAAAAAAAAAAAAAAAAAAAPYXBAAAAAAACLXUNDekMxqa8h%2F40K4moUkGsoc%3DTYfbDKbT3jJPCEVnMYqilB28NHfOPqkca3qaAxGfsyKCs0wRbw"]
        
    }
    
    // MARK: Public functions
    private let tokenService: TokenAcquisitionService<String>
    
    init() {
        let savedToken = UserDefaults.standard.string(forKey: "twitter_guest_token")
        
        tokenService = TokenAcquisitionService(
            initialToken: savedToken,
            getToken: {
                let url = URL(string: TwitterAPI.BASE_API + "guest/activate.json")!
                let request = try! URLRequest(url: url, method: .post)
                return URLSession.shared.rx.response(request: request)
            },
            extractToken: {
                data in
                let json = try parseJSON(data: data)
                
                guard let token = json["guest_token"].string else {
                    throw TwitterAPIError.invalidToken("No token found in response: \(json.stringValue)")
                }
                
                return token
            })
        
        tokenService.token.subscribe(onNext: {
            token in
            UserDefaults.standard.set(token, forKey: "twitter_guest_token")
        })
        .disposed(by: disposeBag)
    }
    
    public func getMediaURLsRx(for url: String, headers: HTTPHeaders? = nil) throws -> Observable<MediaResultURLs> {
        let matchedGroups = url.groups(for: #"https?://(?:(?:www|m(?:obile)?)\.)?twitter\.com/(?:(?:i/web|[^\/]+)/status|statuses)/(?<id>\d+)"#)
        
        guard let splitURL = matchedGroups.get(index: 0),
            let tweetID = splitURL.get(index: 1) else {
                // TODO-EF: Send a non-fatal to Firebase
                print("Couldn't find tweet ID from URL...")
                throw TwitterAPIError.invalidInput("Invalid Twitter URL: \(url)")
        }
        
        return getData(tokenAcquisitionService: tokenService, request: {
            token in
            let url = TwitterAPI.BASE_API + "statuses/show/\(tweetID).json"
            
            var combinedHeaders = TwitterAPI.BASE_HEADERS
                .merging(headers ?? [:],
                         uniquingKeysWith: { (_, new) in new })
            combinedHeaders["x-guest-token"] = token
            
            return try! URLRequest(url: url, method: .get, headers: combinedHeaders)
        }).map {
            _, data in
            let twitterStatus = try JSONDecoder().decode(TwitterAPIType.self, from: data)
            let mediaArray = twitterStatus.extendedEntities.media
            
            guard mediaArray.count > 0 else {
                throw TwitterAPIError.tweetHasNoMedia
            }
            
            let mediaType = mediaArray[0].type
            
            if mediaType == "video" {
                return self.parseVideoInfo(media: mediaArray[0])
            } else if mediaType == "photo" {
                return .images(urls: mediaArray.map { $0.mediaURLHTTPS })
            } else {
                fatalError("UNHANDLED MEDIA TYPE YO")
            }
        }
    }

    // Given a Tweet URL, grab the URL(s) that point to the media.
    //   Meme Folder currently supports either 1 video/gif or 1-4 images.
    public func getMediaURLs(usingTweetURL url: String ) async throws -> MediaResultURLs {
        let matchedGroups = url.groups(for: #"https?://(?:(?:www|m(?:obile)?)\.)?twitter\.com/(?:(?:i/web|[^\/]+)/status|statuses)/(?<id>\d+)"#)
        
        guard let splitURL = matchedGroups.get(index: 0),
            let tweetID = splitURL.get(index: 1) else {
                // TODO-EF: Send a non-fatal to Firebase
                print("Couldn't find tweet ID from URL...")
                throw TwitterAPIError.invalidInput("Invalid Twitter URL: \(url)")
        }
        
        let twitterStatusRaw = try await client.send(.get("statuses/show\(tweetID).json"))
        let twitterStatus = try JSONDecoder().decode(TwitterAPIType.self, from: twitterStatusRaw.data)
        
        let mediaArray = twitterStatus.extendedEntities.media
        
        guard mediaArray.count > 0 else {
            throw TwitterAPIError.tweetHasNoMedia
        }
        
        let mediaType = mediaArray[0].type
        
        if mediaType == "video" {
            return self.parseVideoInfo(media: mediaArray[0])
        } else if mediaType == "photo" {
            return .images(urls: mediaArray.map { $0.mediaURLHTTPS })
        } else {
            fatalError("AHHHH")
        }
    }
    
    // MARK: Twitter API helper functions
    
    ///
    /// Given the media content of a tweet with type == "video", parse out the
    ///     thumbnail and the video variant URLs.
    ///
    func parseVideoInfo(media: Media) -> MediaResultURLs {
        // todo: don't crash if this doesn't exist, throw an error like "unexpectedDataShapeFromAPI"
        var variants = media.videoInfo!.variants
        variants = variants.filter { $0.contentType == "video/mp4" }
        let variantURLs = variants.map { $0.url }
        
        return .videos(thumbnail: media.mediaURLHTTPS, urls: variantURLs)
    }
    
    // We will need this guest token to access Twitter as a guest, until
    //    Twitter approves my developer account
    enum GuestTokenState {
        case fetching, ready(String), error
    }
    var cachedGuestToken = BehaviorRelay<GuestTokenState>(value: .fetching)
    private func refreshAccessToken() async -> Bool {
        return await withCheckedContinuation {
            continuation in
            
            
            continuation.resume(returning: true)
        }
    }
    func getGuestToken() -> Promise<String> {
//        if case let .ready(token) = cachedGuestToken {
            return Promise.value("nyah")
//        }
//
//        return firstly {
//            Alamofire.request(TwitterAPI.BASE_API + "guest/activate.json",
//                              method: .post,
//                              headers: TwitterAPI.BASE_HEADERS)
//                .responseData()
//        }
//        .map { data, _ -> String in
//            let json = try parseJSON(data: data)
//
//            guard let token = json["guest_token"].string else {
//                throw TwitterAPIError.invalidToken("No token found in response: \(json.stringValue)")
//            }
//
//            return token
//        }
    }
    
    //
    // Call the Twitter API with the given endpoint, method, params and headers.
    //
    // Uses the cached guest token, or tries to fetch a new one.
    //
//    func callAPI(endpoint: String, method: HTTPMethod = .get, parameters: Parameters = [:], headers: HTTPHeaders? = nil) -> Promise<Data> {
//
//        return firstly { () -> Promise<String> in
//            getGuestToken()
//        }
//        .then { token -> Promise<(data: Data, response: PMKAlamofireDataResponse)> in
//            var combinedHeaders = TwitterAPI.BASE_HEADERS.merging(headers ?? [:],
//                                                                  uniquingKeysWith: { (_, new) in new })
//            combinedHeaders["x-guest-token"] = token
//
//            return Alamofire.request(TwitterAPI.BASE_API + endpoint, method: method, parameters: parameters, headers: combinedHeaders)
//                .validate()
//                .responseData()
//        }
//        .map { data, _ in
//            return data
//        }
//    }
}
