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
   
   enum TwitterAPIError: Error {
      case invalidToken(String)
      case invalidInput(String)
   }
   
   class GuestTokenResponse: Decodable {
      var guestToken: String
      
      enum CodingKeys: String, CodingKey {
         case guestToken = "guest_token"
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
   
   
   // We will need this guest token to access Twitter as a guest, until
   //    Twitter approves my developer account
   var cachedGuestToken: String?
   func getGuestToken() -> Promise<String> {
      if let cachedGuestToken = cachedGuestToken {
         return Promise.value(cachedGuestToken)
      }
      
//      return Alamofire.request(TwitterDL.BASE_API + "guest/activate.json",
//                               method: .post,
//                               headers: TwitterDL.BASE_HEADERS)
//         .responseData()
      return firstly { () -> Guarantee<String> in
         return Guarantee.value("guh")
      }
      .map { strData -> String in
//         print(data as NSData)
         let data = strData.data(using: .utf8)!
         let token = try JSONDecoder().decode(GuestTokenResponse.self, from: data)
         
         self.cachedGuestToken = token.guestToken
         
         return token.guestToken
      }
      .recover { error -> Promise<String> in
         // TODO-EF: Send a non-fatal to Firebase here
         print("oh nooo couldn't get the guest token")
         switch(error) {
         case let error as DecodingError:
            throw TwitterAPIError.invalidToken("Guest token parse error: \(error.localizedDescription)")
         default:
            throw TwitterAPIError.invalidToken("Guest token error: \(error.localizedDescription)")
         }
      }
   }
   
   // Elliot's note: This will eventually move to the server side, so we can
   //    justify having a subscription. For now just kinda practicing API
   //    calls and data manipulation with Swift.
   public func extractMediaURLs(usingTweetURL url: String) -> Promise<String> {
//      let regex = try! Regex(#"https?://(?:(?:www|m(?:obile)?)\.)?twitter\.com/(?:(?:i/web|[^\/]+)/status|statuses)/(?<id>\d+)"#)
//      let matches = url.match(regex)
//
//      return firstly { return Promise.value(()) }
//         .then {() -> Promise<String>
//         guard let tweetID = matches.subStrings().get(index: 1) else {
//            // TODO-EF: Send a non-fatal to Firebase
//            print("Couldn't find tweet ID from URL...")
//            throw TwitterAPIError.invalidInput("Twitter URL: \(url)")
//         }
//
//         return Promise<String>.value("Fart")
//      }
      return getGuestToken()
   }
   
   public func callAPI() -> Promise<Any> {
      var guestToken: String?
   
      return firstly { () -> Promise<String> in
         getGuestToken()
      }
//      .map {
//
//      }
      .then { token in
         Alamofire.request(TwitterDL.BASE_API
                           + "statuses/show/1213551994964606976.json")
                  .validate()
                  .responseJSON()
      }
      .map { json, _ in
         return json
      }
//      .catch { error in
//         print(error.localizedDescription)
//      }
   }
}
