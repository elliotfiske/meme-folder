//
//  ViewController.swift
//  memefolder
//
//  Created by Elliot Fiske on 1/3/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import AVFoundation
import AVKit
import NSObject_Rx
import RxCocoa
import RxSwift
import UIKit
import Rswift

public class TwitterDLViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    let model = TwitterMediaModel()

    @IBOutlet weak var videoPlayerController: VideoPlayerViewController!
    @IBOutlet weak var errorLabel: UILabel!

    @IBOutlet weak var filesizeButton1: FilesizeButton!
    @IBOutlet weak var filesizeButton2: FilesizeButton!
    @IBOutlet weak var filesizeButton3: FilesizeButton!

    public override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        //        self.parent?.presentationController?.delegate = self
    }

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController)
    {
        videoPlayerController.stopPlaying()
    }

    deinit {
        print("I am being deinitted")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        filesizeButton1.onPress = {
            store.dispatch(SaveToCameraRoll(payload: 0))
        }

        filesizeButton2.onPress = {
            store.dispatch(SaveToCameraRoll(payload: 1))
        }

        filesizeButton3.onPress = {
            store.dispatch(SaveToCameraRoll(payload: 2))
        }

        let filesizeButtons: [FilesizeButton] = [filesizeButton1, filesizeButton2, filesizeButton3]

        store.observableFromPath(keyPath: \.sizeForUrl)
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map {
                sizes -> [(url: String, size: Int)] in
                var result = [(url: String, size: Int)]()
                for (url, size) in sizes {
                    result.append((url: url, size: size))
                }

                result.sort(by: {
                    a, b in
                    a.size < b.size
                })

                return result
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                [weak self] filesizes in

                guard let self = self else { return }

                let buttons: [FilesizeButton] = [
                    self.filesizeButton1, self.filesizeButton2, self.filesizeButton3,
                ]
                buttons.forEach {
                    $0.isHidden = true
                }

                for (ndx, (url, size)) in filesizes.prefix(buttons.count).enumerated() {
                    let button = buttons[ndx]
                    let groups = url.groups(for: "/(\\d+)x(\\d+)/")

                    if let widthHeight = groups.get(index: 0),
                        let width = widthHeight.get(index: 1),
                        let height = widthHeight.get(index: 2)
                    {
                        button.dimensions.text = "\(width) x \(height)"
                    } else {
                        button.dimensions.text = "Save"
                    }
                    button.filesize.text = ByteCountFormatter.string(
                        fromByteCount: Int64(size), countStyle: .file)
                    button.isHidden = false
                }
            })
            .disposed(by: rx.disposeBag)

        rx.disposeBag.insert(
            store.observableFromPath(keyPath: \.savedToCameraRoll)
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: {
                    success in

                    for (index, state) in success {
                        guard let button = filesizeButtons.get(index: index) else { continue }

                        if case .fulfilled = state {
                            button.status = .done
                            button.isDisabled = true
                        } else if case let .error(e) = state {
                            button.status = .error(e)
                            button.isDisabled = false
                        } else if case .pending = state {
                            button.status = .savingToCameraRoll
                            button.isDisabled = true
                        }
                    }
                }),

            store.observableFromPath(keyPath: \.mediaResultURL).apiResult()
                .observe(on: MainScheduler.instance)
                .compactMap {
                    if let thumb = $0.thumbnail {
                        return thumb
                    }
                    return nil
                }
                .distinctUntilChanged()
                .subscribe(onNext: {
                    [weak self] (thumb: String) in
                    self?.videoPlayerController.thumbnailView.source = thumb
                }),

            store.observableFromPath(keyPath: \.mediaResultURL)
                .apiError()
                .map {
                    err in
                    if let err = err as? ElliotError {
                        return err.userMessage
                    }

                    return err.localizedDescription
                }
                .bind(to: errorLabel.rx.text),

            store.observableFromPath(keyPath: \.mediaResultURL)
                .map { $0.getError() == nil }
                .bind(to: errorLabel.rx.isHidden),

            store.observableFromPath(keyPath: \.mediaResultURL)
                .map { $0.getError() != nil }
                .bind(to: videoPlayerController.rx.isHidden),

            store.observableFromPath(keyPath: \.localMediaURL).apiResult()
                .distinctUntilChanged()
                .map {
                    url in
                    return AVPlayerItem(url: url)
                }
                .bind(to: videoPlayerController.itemToPlay),

            store.observableFromPath(keyPath: \.downloadedMediaProgress)
                .map { Float($0) }
                .bind(to: videoPlayerController.loadingProgress)
        )

    }
}
