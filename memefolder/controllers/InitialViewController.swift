//
//  InitialViewController.swift
//  memefolder
//
//  Created by Elliot Fiske on 1/10/20.
//  Copyright © 2020 Meme Folder. All rights reserved.
//

import UIKit
import YoutubeDL
import ReSwift
import RxSwift

class InitialViewController: UIViewController {

    @IBOutlet weak var testActivityView: UIActivityIndicatorView!
    @IBOutlet weak var coolButton: UIButton!
    
    typealias StoreSubscriberStateType = TwitterMediaGrabberState
    
    @IBOutlet weak var recentPhotosContainer: UIView!
    
    var recentPhotosController: RecentPhotosCollectionViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // todo: this should move somewhere else, maybe like a "InitialLoadEpic" or something
        if let savedToken = UserDefaults.standard.string(forKey: "twitter_guest_token") {
            store.dispatch(TwitterAPIAction.setToken(savedToken))
        }
        
        store.observableFromPath(keyPath: \.coolPokemonFact)
            .map { if case .pending = $0 { return false } else { return true } }
            .debounce(.milliseconds(250), scheduler: MainScheduler.instance)
            .bind(to: testActivityView.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
//        store.subscribeToValue(keyPath: \.coolPokemonFact)
//            .compactMap {
//                if case let .fulfilled(str) = $0 {
//                    return str
//                } else if case let .error(error) = $0 {
//                    return error.localizedDescription
//                } else {
//                    return nil
//                }
//            }
//            .bind(to: coolButton.rx.title())
//            .disposed(by: rx.disposeBag)
//
//        coolButton.rx.tap
//            .subscribe {
//                _ in
//                store.dispatch(NumbersAPIAction.getNumberFact(3))
//            }
//            .disposed(by: rx.disposeBag)
        
        
        // TODO: I'll almost certainly need to do this again so I should make a helper for it.
        let storyboard = UIStoryboard(name: "RecentPhotosCollectionViewController", bundle: nil)
        guard let controller = storyboard.instantiateInitialViewController() else {
            return
        }
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(controller)
        recentPhotosContainer.addSubview(controller.view)
        
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: recentPhotosContainer.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: recentPhotosContainer.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: recentPhotosContainer.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: recentPhotosContainer.bottomAnchor)
        ])
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        let controlla = TwitterDLViewController.loadFromNib()
        
        // Simulates getting a Tweet URL via the Share panel and passing it along
//        controlla.tweetURLToLoad = "https://twitter.com/animatedtext/status/1220134801430024193?s=20"     // 0:03 gif
//        controlla.tweetURLToLoad = "https://twitter.com/CultureCrave/status/1226622427599257601"          // 0:16 video
//        controlla.tweetURLToLoad = "https://twitter.com/cyberglittter/status/1413344653408153600?s=20" // 2 Images
        
        controlla.tweetURLToLoad = "https://twitter.com/matthen2/status/1543226572592783362"    // 0:55 video
        
        controlla.presentationController?.delegate = controlla
        present(controlla, animated: true)
        
        
    }
}
