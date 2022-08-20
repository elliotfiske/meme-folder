//
//  TwitterDownloader.swift
//  YoutubeDL
//
//  Created by Elliot Fiske on 1/4/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import Alamofire
import Foundation
import NSObject_Rx
import RxAlamofire
import RxRelay
import RxSwift
import SwiftyJSON

public class TwitterAPI: HasDisposeBag {

    public enum MediaResultURLs {
        /// 1-4 images in a tweet
        case images(urls: [String])

        /// Videos can have multiple URLs, for the different qualities.
        case videos(thumbnail: String, urls: [String])
    }

    public struct MediaResultURLs_struct {
        public struct Video: Equatable {
            var url: String
        }

        public let thumbnail: String?
        public let images: [String]?
        public let videos: [Video]?
    }

    public static let sharedInstance: TwitterAPI = TwitterAPI()

    static let BASE_API = "https://api.twitter.com/1.1/"
    static let BASE_HEADERS: HTTPHeaders = [
        // yoinked from YoutubeDL's repo :3 (remember to switch over to my own at some point)
        "Authorization":
            "Bearer AAAAAAAAAAAAAAAAAAAAAPYXBAAAAAAACLXUNDekMxqa8h%2F40K4moUkGsoc%3DTYfbDKbT3jJPCEVnMYqilB28NHfOPqkca3qaAxGfsyKCs0wRbw",
        "Accept": "application/json",
    ]

    // MARK: Public functions
    private let tokenService: TokenAcquisitionService<String>

    init() {
        let savedToken = UserDefaults.standard.string(forKey: "twitter_guest_token") ?? "bad_token"

        tokenService = TokenAcquisitionService(
            initialToken: savedToken,
            getToken: {
                let request = try! urlRequest(
                    .post,
                    TwitterAPI.BASE_API + "guest/activate.json",
                    headers: TwitterAPI.BASE_HEADERS
                )
                return URLSession.shared.rx.response(request: request)
            },
            extractToken: {
                data in
                let json = try parseJSON(data: data)

                guard let token = json["guest_token"].string else {
                    let error = ElliotError(
                        localizedMessage: "I couldn't connect to Twitter...",
                        developerMessage:
                            "No guest_token in return value from guest/activate.json: \(json.rawString() ?? "<empty>")",
                        category: .unexpectedDataShape
                    )

                    throw error
                }

                return token
            }
        )

        tokenService.token.subscribe(onNext: {
            token in
            UserDefaults.standard.set(token, forKey: "twitter_guest_token")
        })
        .disposed(by: disposeBag)
    }

    public static func getTweetIDFrom(url: String) -> String? {
        let matchedGroups = url.groups(
            for:
                #"(?:https?://)?(?:(?:www|m(?:obile)?)\.)?twitter\.com/(?:(?:i/web|[^\/]+)/status|statuses)/(?<id>\d+)"#
        )

        guard let splitURL = matchedGroups.get(index: 0),
            let tweetID = splitURL.get(index: 1)
        else {
            return nil
        }

        return tweetID
    }

    public func getMediaURLsRx(
        for url: String,
        headers: HTTPHeaders? = nil
    ) throws -> Observable<
        MediaResultURLs_struct
    > {
        guard let tweetID = TwitterAPI.getTweetIDFrom(url: url) else {
            // TODO-EF: Send a non-fatal to Firebase
            throw ElliotError(
                localizedMessage: "That doesn't look like a link to a Tweet.",
                developerMessage: "Couldn't parse Tweet ID from Tweet: \(url)",
                category: .invalidUserInput)
        }

        return getData(
            tokenAcquisitionService: tokenService,
            request: {
                token in
                let url = TwitterAPI.BASE_API + "statuses/show/\(tweetID).json"

                let params: Parameters = [
                    "cards_platform": "Web-12",
                    "include_cards": "1",
                    "include_reply_count": "1",
                    "include_user_entities": "0",
                    "tweet_mode": "extended",
                ]

                var finalHeaders = HTTPHeaders(TwitterAPI.BASE_HEADERS.dictionary)
                finalHeaders["x-guest-token"] = token

                return try! urlRequest(.get, url, parameters: params, headers: finalHeaders)
            }
        ).map {
            response, data in
            guard response.statusCode != 404 else {
                throw ElliotError(
                    localizedMessage: "I couldn't find a Tweet at that URL.",
                    developerMessage: "Error 404 for tweet URL: \(url)", category: .networkError)
            }

            let twitterStatus = try JSONDecoder().decode(TwitterAPIType.self, from: data)
            let optMediaArray = twitterStatus.extendedEntities?.media

            guard let mediaArray = optMediaArray, mediaArray.count > 0 else {
                throw ElliotError(
                    localizedMessage: "It looks like that Tweet doesn't have any videos or images.",
                    developerMessage: "Media array empty for tweet with URL \(url)",
                    category: .invalidUserInput)
            }

            let mediaType = mediaArray.last!.type

            if mediaType == "video" || mediaType == "animated_gif" {
                return try self.parseVideoInfo(media: mediaArray.last!)
            } else if mediaType == "photo" {
                let images: [String] = try mediaArray.map {
                    guard let url = $0.mediaURLHTTPS else {
                        throw ElliotError(
                            localizedMessage:
                                "I couldn't find the download link for the media in this Tweet...",
                            developerMessage: "No URL in media object: \(String(describing: $0))",
                            category: .unexpectedDataShape)
                    }
                    return url
                }
                return MediaResultURLs_struct(thumbnail: nil, images: images, videos: nil)
            } else {
                throw ElliotError(
                    localizedMessage:
                        "I can't download the type of media that's attached to this Tweet.",
                    developerMessage:
                        "Unknown media type \(String(describing: mediaType)) on Tweet.",
                    category: .unexpectedDataShape)
            }
        }
    }

    func getMediaSize(for url: String) throws -> Observable<Int> {
        return getData(
            tokenAcquisitionService: tokenService,
            request: {
                token in

                var finalHeaders = HTTPHeaders(TwitterAPI.BASE_HEADERS.dictionary)
                finalHeaders["x-guest-token"] = token

                return try! urlRequest(.head, url, headers: finalHeaders)
            }
        )
        .map {
            response, data in
            guard let len = response.headers.value(for: "Content-Length") else {
                throw ElliotError(
                    localizedMessage: "Couldn't get size of video...",
                    developerMessage:
                        "Content-Length headers didn't show up. Headers: \(response.headers)",
                    category: .unexpectedDataShape)
            }

            guard let numLen = Int(len) else {
                throw ElliotError(
                    localizedMessage: "Couldn't get size of video...",
                    developerMessage: "Content-Length header not number: \(response.headers)",
                    category: .unexpectedDataShape)
            }

            return numLen
        }
    }

    /// Configuration closure for AlamoFire that tells it where to download the video.
    let destination: DownloadRequest.Destination = { url, _ in
        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        documentsURL.appendPathComponent("MemeFolder-download.mp4")

        return (documentsURL, [.removePreviousFile])
    }

    public func downloadMedia(
        atUrl url: String
    ) -> Observable<
        (progress: Double, localUrl: URL?)
    > {
        return Observable<(progress: Double, localUrl: URL?)>.create {
            subscriber in

            guard let parsedUrl = URL(string: url) else {
                subscriber.onError(
                    ElliotError(
                        localizedMessage: "Couldn't get media from Tweet",
                        developerMessage: "Error parsing media URL. Got URL: \(url)",
                        category: .unexpectedDataShape))
                return Disposables.create()
            }

            let cancelToken = AF.download(parsedUrl, to: self.destination)
                .downloadProgress {
                    progress in
                    subscriber.onNext((progress.fractionCompleted, nil))
                }
                .response {
                    response in
                    subscriber.onNext((1, response.fileURL))
                }

            return Disposables.create {
                cancelToken.cancel()
            }
        }
        .do { progress, localUrl in
            guard let url = localUrl, progress >= 1.0 else { return }

            try FileManager.default.setAttributes(
                [.creationDate: NSDate.now], ofItemAtPath: url.path)
        }
    }

    // MARK: Twitter API helper functions

    ///
    /// Given the media content of a tweet with type == "video", parse out the
    ///     thumbnail and the video variant URLs.
    ///
    func parseVideoInfo(media: Media) throws -> MediaResultURLs_struct {
        guard let variants = media.videoInfo?.variants else {
            throw ElliotError(
                localizedMessage: "Couldn't get video from Tweet :(",
                developerMessage:
                    "Bad video info. Expected variants, got \(String(describing: media.videoInfo))",
                category: .unexpectedDataShape)
        }

        let filteredVariants = variants.filter { $0.contentType == "video/mp4" }
        let videoVariants: [MediaResultURLs_struct.Video] = try filteredVariants.map {
            guard let url = $0.url else {
                throw ElliotError(
                    localizedMessage: "Couldn't get video from Tweet :(",
                    developerMessage:
                        "No URL for variant. All video variants: \(String(describing: filteredVariants))",
                    category: .unexpectedDataShape)
            }
            return MediaResultURLs_struct.Video(url: url)
        }

        return MediaResultURLs_struct(
            thumbnail: media.mediaURLHTTPS,
            images: nil,
            videos: videoVariants
        )
    }
}
