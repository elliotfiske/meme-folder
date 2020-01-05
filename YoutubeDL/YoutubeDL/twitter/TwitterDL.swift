//
//  TwitterDL.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 1/4/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import Foundation

public class TwitterDL {
   static let BEARER_TOKEN = "Bearer AAAAAAAAAAAAAAAAAAAAAPYXBAAAAAAACLXUNDekMxqa8h%2F40K4moUkGsoc%3DTYfbDKbT3jJPCEVnMYqilB28NHfOPqkca3qaAxGfsyKCs0wRbw"
   
   static let API_BASE = "https://api.twitter.com/1.1/"
   
   // We will need this guest token to access Twitter as a guest, until
   //    Twitter approves my developer account
   static var guestToken: String?
   
   public static func callAPI() {
      if guestToken == nil {
         let tokenURL = URL(string: API_BASE + "guest/activate.json")!
         let headers = [
            "Authorization" : BEARER_TOKEN,
            "Accept" : "application/json"
         ]
         
         
      }
   }
}
