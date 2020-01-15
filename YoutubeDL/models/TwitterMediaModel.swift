//
//  TwitterMediaModel.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 1/10/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import Foundation

public class TwitterMediaModel {
   var mediaURL: String?
   var thumbnailURL: String?
   
   public enum MediaState {
      case nothingDownloaded
      
      case downloadingThumbnail(Double)   // Value is the download progress 0 -> 1.0
      case downloadedThumbnail
      
      case downloadingMedia(Double)       // Value is the download progress 0 -> 1.0
      case downloadedMedia
      
      case savingMediaToCameraRoll
      case finished
   }
}
