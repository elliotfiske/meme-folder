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

public class TwitterDL {
   
   enum TwitterAPIError: Error {
      case invalidToken(String)
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
   
   
   // We will need this guest token to access Twitter as a guest, until
   //    Twitter approves my developer account
   var guestToken: String?
   func getGuestToken() -> Promise<String> {
      if let guestToken = guestToken {
         return Promise.value(guestToken)
      }
      
      let headers: HTTPHeaders = [
         "Authorization" : TwitterDL.BEARER_TOKEN,
         "Accept" : "application/json"
      ]
      
      return Alamofire.request(TwitterDL.BASE_API + "guest/activate.json",
                               method: .post,
                               headers: headers)
         .responseData()
         .map { data, _ -> String in
            print(data as NSData)
            let token = try JSONDecoder().decode(GuestTokenResponse.self, from: data)
            return token.guestToken
         }
         .recover { error -> Promise<String> in
            // TODO-EF: Send a non-fatal to Firebase here
            print("oh nooo couldn't get the guest token")
            throw error
         }
   }
   
   public func callAPI() {
      var guestToken: String?
      
      let url = "https://twitter.com/pokimanelol/status/1213551994964606976?s=20"
      
      let regex = try! NSRegularExpression(pattern: #"https?://(?:(?:www|m(?:obile)?)\.)?twitter\.com/(?:(?:i/web|[^\/]+)/status|statuses)/(?<id>\d+)"#
      )
      let range = NSRange(url.startIndex..<url.endIndex, in: url)
      
      if let match = regex.firstMatch(in: url, options: [], range: range) {
         let nsrange = match.range(at: 1)
         if nsrange.location != NSNotFound,
            let range = Range(nsrange, in: url)
         {
            print("Cool: \(url[range])")
         }
      }
      
      firstly {
         getGuestToken()
      }
      .done { guestToken = $0 }
      .then { Alamofire.request(TwitterDL.BASE_API
         + "statuses/show/1213551994964606976.json").validate().responseJSON()
      }
      .ensure { print("haha neat") }
      .catch { error in
         print(error.localizedDescription)
      }
   }
}
