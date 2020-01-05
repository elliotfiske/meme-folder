//
//  TwitterDL.swift
//  youtubedlswift
//
//  Created by Elliot Fiske on 1/4/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import Foundation
import PromiseKit
import PMKAlamofire

public class TwitterDL {
   static let BEARER_TOKEN = "Bearer AAAAAAAAAAAAAAAAAAAAAPYXBAAAAAAACLXUNDekMxqa8h%2F40K4moUkGsoc%3DTYfbDKbT3jJPCEVnMYqilB28NHfOPqkca3qaAxGfsyKCs0wRbw"
   
   static let BASE_API = "https://api.twitter.com/1.1/"
   
   // We will need this guest token to access Twitter as a guest, until
   //    Twitter approves my developer account
   static func getGuestToken() -> Promise<String> {
      let headers: HTTPHeaders = [
         "Authorization" : BEARER_TOKEN,
         "Accept" : "application/json"
      ]
      
      return Alamofire.request(BASE_API + "guest/activate.json",
                               method: .post,
                               headers: headers)
         .responseJSON()
         .map { json, _ -> String in
            print(json)
            return "test"
         }
   }
   
   public static func callAPI() {
      var guestToken: String?
      
      firstly {
         getGuestToken()
      }
      .done { guestToken = $0 }
      .catch { error in
         print(error.localizedDescription)
      }
   }
}
