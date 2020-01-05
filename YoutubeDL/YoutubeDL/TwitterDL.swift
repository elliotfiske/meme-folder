//
//  TwitterDL.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 1/4/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import Foundation
import RxSwift

public class TwitterDL {
   let BEARER_TOKEN = "Bearer AAAAAAAAAAAAAAAAAAAAAPYXBAAAAAAACLXUNDekMxqa8h%2F40K4moUkGsoc%3DTYfbDKbT3jJPCEVnMYqilB28NHfOPqkca3qaAxGfsyKCs0wRbw"
   
   // We will need this guest token to access Twitter as a guest, until
   //    Twitter approves my developer account
   static var guestToken: String?
   
   static func callAPI() {
      if guestToken == nil {
         
      }
   }
}
