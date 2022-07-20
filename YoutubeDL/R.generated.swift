//
// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift
//

import Foundation
import Rswift
import UIKit

/// This `R` struct is generated and contains references to static resources.
struct R: Rswift.Validatable {
  fileprivate static let applicationLocale = hostingBundle.preferredLocalizations.first.flatMap { Locale(identifier: $0) } ?? Locale.current
  fileprivate static let hostingBundle = Bundle(for: R.Class.self)

  /// Find first language and bundle for which the table exists
  fileprivate static func localeBundle(tableName: String, preferredLanguages: [String]) -> (Foundation.Locale, Foundation.Bundle)? {
    // Filter preferredLanguages to localizations, use first locale
    var languages = preferredLanguages
      .map { Locale(identifier: $0) }
      .prefix(1)
      .flatMap { locale -> [String] in
        if hostingBundle.localizations.contains(locale.identifier) {
          if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
            return [locale.identifier, language]
          } else {
            return [locale.identifier]
          }
        } else if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
          return [language]
        } else {
          return []
        }
      }

    // If there's no languages, use development language as backstop
    if languages.isEmpty {
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages = [developmentLocalization]
      }
    } else {
      // Insert Base as second item (between locale identifier and languageCode)
      languages.insert("Base", at: 1)

      // Add development language as backstop
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages.append(developmentLocalization)
      }
    }

    // Find first language for which table exists
    // Note: key might not exist in chosen language (in that case, key will be shown)
    for language in languages {
      if let lproj = hostingBundle.url(forResource: language, withExtension: "lproj"),
         let lbundle = Bundle(url: lproj)
      {
        let strings = lbundle.url(forResource: tableName, withExtension: "strings")
        let stringsdict = lbundle.url(forResource: tableName, withExtension: "stringsdict")

        if strings != nil || stringsdict != nil {
          return (Locale(identifier: language), lbundle)
        }
      }
    }

    // If table is available in main bundle, don't look for localized resources
    let strings = hostingBundle.url(forResource: tableName, withExtension: "strings", subdirectory: nil, localization: nil)
    let stringsdict = hostingBundle.url(forResource: tableName, withExtension: "stringsdict", subdirectory: nil, localization: nil)

    if strings != nil || stringsdict != nil {
      return (applicationLocale, hostingBundle)
    }

    // If table is not found for requested languages, key will be shown
    return nil
  }

  /// Load string from Info.plist file
  fileprivate static func infoPlistString(path: [String], key: String) -> String? {
    var dict = hostingBundle.infoDictionary
    for step in path {
      guard let obj = dict?[step] as? [String: Any] else { return nil }
      dict = obj
    }
    return dict?[key] as? String
  }

  static func validate() throws {
    try intern.validate()
  }

  /// This `R.file` struct is generated, and contains static references to 1 files.
  struct file {
    /// Resource file `rswift`.
    static let rswift = Rswift.FileResource(bundle: R.hostingBundle, name: "rswift", pathExtension: "")

    /// `bundle.url(forResource: "rswift", withExtension: "")`
    static func rswift(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.rswift
      return fileResource.bundle.url(forResource: fileResource)
    }

    fileprivate init() {}
  }

  /// This `R.image` struct is generated, and contains static references to 4 images.
  struct image {
    /// Image `gear_cloud`.
    static let gear_cloud = Rswift.ImageResource(bundle: R.hostingBundle, name: "gear_cloud")
    /// Image `pause`.
    static let pause = Rswift.ImageResource(bundle: R.hostingBundle, name: "pause")
    /// Image `play`.
    static let play = Rswift.ImageResource(bundle: R.hostingBundle, name: "play")
    /// Image `twitter_logo`.
    static let twitter_logo = Rswift.ImageResource(bundle: R.hostingBundle, name: "twitter_logo")

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "gear_cloud", bundle: ..., traitCollection: ...)`
    static func gear_cloud(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.gear_cloud, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "pause", bundle: ..., traitCollection: ...)`
    static func pause(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.pause, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "play", bundle: ..., traitCollection: ...)`
    static func play(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.play, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "twitter_logo", bundle: ..., traitCollection: ...)`
    static func twitter_logo(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.twitter_logo, compatibleWith: traitCollection)
    }
    #endif

    fileprivate init() {}
  }

  /// This `R.nib` struct is generated, and contains static references to 4 nibs.
  struct nib {
    /// Nib `AVVideoPlayerView`.
    static let avVideoPlayerView = _R.nib._AVVideoPlayerView()
    /// Nib `TwitterDLViewController`.
    static let twitterDLViewController = _R.nib._TwitterDLViewController()
    /// Nib `VideoControlsView`.
    static let videoControlsView = _R.nib._VideoControlsView()
    /// Nib `VideoPlayerViewController`.
    static let videoPlayerViewController = _R.nib._VideoPlayerViewController()

    #if os(iOS) || os(tvOS)
    /// `UINib(name: "AVVideoPlayerView", in: bundle)`
    @available(*, deprecated, message: "Use UINib(resource: R.nib.avVideoPlayerView) instead")
    static func avVideoPlayerView(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.avVideoPlayerView)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UINib(name: "TwitterDLViewController", in: bundle)`
    @available(*, deprecated, message: "Use UINib(resource: R.nib.twitterDLViewController) instead")
    static func twitterDLViewController(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.twitterDLViewController)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UINib(name: "VideoControlsView", in: bundle)`
    @available(*, deprecated, message: "Use UINib(resource: R.nib.videoControlsView) instead")
    static func videoControlsView(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.videoControlsView)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UINib(name: "VideoPlayerViewController", in: bundle)`
    @available(*, deprecated, message: "Use UINib(resource: R.nib.videoPlayerViewController) instead")
    static func videoPlayerViewController(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.videoPlayerViewController)
    }
    #endif

    static func avVideoPlayerView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> UIKit.UIView? {
      return R.nib.avVideoPlayerView.instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
    }

    static func twitterDLViewController(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> UIKit.UIView? {
      return R.nib.twitterDLViewController.instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
    }

    static func videoControlsView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> UIKit.UIView? {
      return R.nib.videoControlsView.instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
    }

    static func videoPlayerViewController(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> UIKit.UIView? {
      return R.nib.videoPlayerViewController.instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
    }

    fileprivate init() {}
  }

  fileprivate struct intern: Rswift.Validatable {
    fileprivate static func validate() throws {
      try _R.validate()
    }

    fileprivate init() {}
  }

  fileprivate class Class {}

  fileprivate init() {}
}

struct _R: Rswift.Validatable {
  static func validate() throws {
    #if os(iOS) || os(tvOS)
    try nib.validate()
    #endif
  }

  #if os(iOS) || os(tvOS)
  struct nib: Rswift.Validatable {
    static func validate() throws {
      try _VideoControlsView.validate()
    }

    struct _AVVideoPlayerView: Rswift.NibResourceType {
      let bundle = R.hostingBundle
      let name = "AVVideoPlayerView"

      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> UIKit.UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
      }

      fileprivate init() {}
    }

    struct _TwitterDLViewController: Rswift.NibResourceType {
      let bundle = R.hostingBundle
      let name = "TwitterDLViewController"

      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> UIKit.UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
      }

      fileprivate init() {}
    }

    struct _VideoControlsView: Rswift.NibResourceType, Rswift.Validatable {
      let bundle = R.hostingBundle
      let name = "VideoControlsView"

      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> UIKit.UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
      }

      func secondView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> UIKit.UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[1] as? UIKit.UIView
      }

      static func validate() throws {
        if UIKit.UIImage(named: "play", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'play' is used in nib 'VideoControlsView', but couldn't be loaded.") }
        if #available(iOS 11.0, tvOS 11.0, *) {
        }
      }

      fileprivate init() {}
    }

    struct _VideoPlayerViewController: Rswift.NibResourceType {
      let bundle = R.hostingBundle
      let name = "VideoPlayerViewController"

      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> UIKit.UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
      }

      fileprivate init() {}
    }

    fileprivate init() {}
  }
  #endif

  fileprivate init() {}
}