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
        public struct Video {
            var url: String
        }

        let thumbnail: String?
        let images: [String]?
        let videos: [Video]?
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
                #"(https?://)?(?:(?:www|m(?:obile)?)\.)?twitter\.com/(?:(?:i/web|[^\/]+)/status|statuses)/(?<id>\d+)"#
        )

        guard let splitURL = matchedGroups.get(index: 0),
            let tweetID = splitURL.get(index: 1)
        else {
            // TODO-EF: Send a non-fatal to Firebase
            print("Couldn't find tweet ID from URL...")
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
            print("Couldn't find tweet ID from URL...")
            throw TwitterAPIError.invalidInput("Invalid Twitter URL: \(url)")
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
                let error = NSError()
                throw TwitterAPIError.invalidInput("That doesn't seem to point to an actual tweet.")
            }

            let twitterStatus = try JSONDecoder().decode(TwitterAPIType.self, from: data)
            let optMediaArray = twitterStatus.extendedEntities?.media

            guard let mediaArray = optMediaArray, mediaArray.count > 0 else {
                throw TwitterAPIError.tweetHasNoMedia
            }

            let mediaType = mediaArray.last!.type

            if mediaType == "video" {
                return try self.parseVideoInfo(media: mediaArray.last!)
            } else if mediaType == "photo" {
                let images: [String] = try mediaArray.map {
                    guard let url = $0.mediaURLHTTPS else {
                        throw TwitterAPIError.unexpectedDataShape(
                            "No URL in media array: \(String(describing: $0))"
                        )
                    }
                    return url
                }
                return MediaResultURLs_struct(thumbnail: nil, images: images, videos: nil)
            } else {
                throw TwitterAPIError.unexpectedDataShape(
                    "Unknown media type \(String(describing: mediaType))"
                )
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
                throw TwitterAPIError.unexpectedDataShape(
                    "Couldn't get Content-Length headers. All headers: \(response.headers)"
                )
            }

            guard let numLen = Int(len) else {
                throw TwitterAPIError.unexpectedDataShape("Content-Length not number: \(len)")
            }

            return numLen
        }
    }

    let destination: DownloadRequest.Destination = { url, _ in
        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        documentsURL.appendPathComponent("familyguy.mp4")

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
                subscriber.onError(TwitterAPIError.invalidInput("Bad Media URL: \(url)"))
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
    }

    // MARK: Twitter API helper functions

    ///
    /// Given the media content of a tweet with type == "video", parse out the
    ///     thumbnail and the video variant URLs.
    ///
    func parseVideoInfo(media: Media) throws -> MediaResultURLs_struct {
        guard let variants = media.videoInfo?.variants else {
            throw TwitterAPIError.unexpectedDataShape(
                "Bad video info, expected variants: \(String(describing: media.videoInfo))"
            )
        }

        let filteredVariants = variants.filter { $0.contentType == "video/mp4" }
        let videoVariants: [MediaResultURLs_struct.Video] = try filteredVariants.map {
            guard let url = $0.url else {
                throw TwitterAPIError.unexpectedDataShape("No URL for video: \($0)")
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
