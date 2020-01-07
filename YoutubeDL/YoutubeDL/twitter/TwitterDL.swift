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
import SwiftExpression

public class TwitterDL {
   struct GuestTokenResponse: Decodable {
      var guest_token: String
   }
   
   struct StatusDetails: Decodable {
      var extended_entities: ExtendedEntities
      
      struct ExtendedEntities: Decodable {
         var media: [MediaEntity]
         
         struct MediaEntity: Decodable {
            var media_url: String
            var media_url_https: String
         }
      }
   }
   
   public static let sharedInstance: TwitterDL = TwitterDL()
   
   // yoinked from YoutubeDL's repo :3
   static let BEARER_TOKEN = "Bearer AAAAAAAAAAAAAAAAAAAAAPYXBAAAAAAACLXUNDekMxqa8h%2F40K4moUkGsoc%3DTYfbDKbT3jJPCEVnMYqilB28NHfOPqkca3qaAxGfsyKCs0wRbw"
   static let BASE_API = "https://api.twitter.com/1.1/"
   
   static let BASE_HEADERS: HTTPHeaders = [
      "Authorization" : TwitterDL.BEARER_TOKEN,
      "Accept" : "application/json"
   ]
   
   // Elliot's note: This will eventually move to the server side, so we can
   //    justify selling a subscription. For now just kinda practicing API
   //    calls and data manipulation with Swift.
   public func extractMediaURLs(usingTweetURL url: String) throws -> Promise<String> {
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
         let status_deets = try JSONDecoder().decode(StatusDetails.self, from: data)
         return status_deets.extended_entities.media[0].media_url_https
      }
   }
   
   // MARK - Twitter API helper functions
   
   // We will need this guest token to access Twitter as a guest, until
   //    Twitter approves my developer account
   var cachedGuestToken: String?
   func getGuestToken() -> Promise<String> {
      if let cachedGuestToken = cachedGuestToken {
         return Promise.value(cachedGuestToken)
      }
      
      return firstly {
         Alamofire.request(TwitterDL.BASE_API + "guest/activate.json",
                           method: .post,
                           headers: TwitterDL.BASE_HEADERS)
            .responseData()
      }
      .map { data, _ -> String in
         let token = try JSONDecoder().decode(GuestTokenResponse.self, from: data)
         
         self.cachedGuestToken = token.guest_token
         
         return token.guest_token
      }
      .recover { error -> Promise<String> in
         // TODO-EF: Send a non-fatal to Firebase here
         print("oh nooo couldn't get the guest token")
         switch(error) {
         case DecodingError.dataCorrupted(let context):
            throw TwitterAPIError.invalidToken("Guest token parse error: \(context.debugDescription)")
         default:
            throw TwitterAPIError.invalidToken("Guest token error: \(error.localizedDescription)")
         }
      }
   }
   
   //
   // Call the Twitter API with the given endpoint, method, params and headers.
   //
   // Uses the cached guest token, or
   //
   public func callAPI(endpoint: String, method: HTTPMethod = .get, parameters: Parameters = [:], headers: HTTPHeaders? = nil) -> Promise<Data> {

      return firstly { () -> Promise<String> in
         getGuestToken()
      }
      .then { token -> Promise<(data: Data, response: PMKAlamofireDataResponse)> in
         var combinedHeaders = TwitterDL.BASE_HEADERS.merging(headers ?? [:],
                                 uniquingKeysWith: { (_, new) in new })
         combinedHeaders["x-guest-token"] = token
         
         return Alamofire.request(TwitterDL.BASE_API + endpoint, method: method, parameters: parameters, headers: combinedHeaders)
            .validate()
            .responseData()
      }
      .map { data, _ in
         return data
      }
   }
}
