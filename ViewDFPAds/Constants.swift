//
//  Constants.swift
//  ViewDFPAds
//

import Foundation
import GoogleMobileAds

struct Constants {
    
    /// Banner ad unit ID.
    static let AdMobAdUnitID = "ca-app-pub-3940256099942544/2934735716"
    
    /// DFP PPID ad unit ID.
    static let DFPPPIDAdUnitID = "/6499/example/APIDemo/PPID"
    
    ///DFP Interstitial ad unit ID.
    static let DFPInterstitialAdUnitID = "/6499/example/interstitial"
    
    /// DFP custom targeting ad unit ID.
    static let DFPCustomTargetingAdUnitID = "/6499/example/APIDemo/CustomTargeting"
    
    /// DFP category exclusions ad unit ID.
    static let DFPCategoryExclusionsAdUnitID = "/6499/example/APIDemo/CategoryExclusion"
    
    /// Dogs category excliusion.
    static let CategoryExclusionDogs = "apidemo_exclude_dogs"
    
    /// Cats category exclusion.
    static let CategoryExclusionCats = "apidemo_exclude_cats"
    
    /// DFP ad sizes ad unit ID.
    static let DFPAdSizesAdUnitID = "/6499/example/APIDemo/AdSizes"
    
    /// DFP app events ad unit ID.
    static let DFPAppEventsAdUnitID = "/6499/example/APIDemo/AppEvents"
    
    /// DFP Fluid ad size ad unit ID.
    static let DFPFluidAdSizeAdUnitID = "/6499/example/APIDemo/Fluid"
    
    static let Interstitial = "Interstitial"
    
    static let ServiceDisabled = "Service Disabled"
    
    static let Empty = ""
    
    static let adSizesInterstitial = [NSValue]()
    static let adSize120x20 = [NSValueFromGADAdSize(GADAdSizeFromCGSize(CGSize(width: 120, height: 20)))]
    static let adSize300x50 = [NSValueFromGADAdSize(kGADAdSizeBanner)]
    static let adSize300x250 = [NSValueFromGADAdSize(kGADAdSizeMediumRectangle)]
    static let adSizeMulti = Constants.adSize120x20 + Constants.adSize300x50 + Constants.adSize300x250
    
    static let AdPickerDictionaryLiteral: DictionaryLiteral = [
        "Multi" : Constants.adSizeMulti,
        "320x50" : Constants.adSize300x50,
        "300x250" : Constants.adSize300x250,
        "120x20 Custom " : Constants.adSize120x20,
        "Interstitial" : Constants.adSizesInterstitial]
}
