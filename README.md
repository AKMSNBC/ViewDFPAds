# ViewDFPAds

Single View Application for viewing DFP ads.

Use default SDK test adunit values or override with custom adunit values in textfield.

Use picker to select banner ad size or interstitial ad.

Use switch to enable location data and add location data into ad call for geo targeting.

Ads are displayed on bottom of screen.  Ad request error messages are displayed on botton of screen.

# Set up instructions
This app integrates Google Ads SDK using the recommended pod feature.

Streamlined CocoaPods manager.  Similar to NPM, but for Xcode project library dependencies.
[https://guides.cocoapods.org/using/getting-started.html](https://guides.cocoapods.org/using/getting-started.html)

Each iOS example app includes a Podfile and a Podfile.lock. The Podfile.lock
tracks the version of each Pod specified in the Podfile that was used to build
the release of the iOS example apps.

1. Run `pod install` in the same directory as the Podfile.
1. [Optional] Run `pod update` to get the latest version of the SDK.
1. Open the .xcworkspace file with Xcode and run the app.

# References
[https://developers.google.com/mobile-ads-sdk/docs/dfp/ios/quick-start](https://developers.google.com/mobile-ads-sdk/docs/dfp/ios/quick-start)

# Screen Shot instructions

Launch screens on iPhone 5s and iPhone 8.

![iphone5s screenshot](/images/iphone5s.png)
![iphone8 screenshot](/images/iphone8.png)

Touch `Display Ad` button to show default ad.

![iphone8defaultad screenshot](/images/iphone8defaultad.png)

Touch `Debug Ad` button to open debug ad panel.
Follow Google Ads SDK instructions to debug ads in DFP.
[https://developers.google.com/mobile-ads-sdk/docs/dfp/ios/debug](https://developers.google.com/mobile-ads-sdk/docs/dfp/ios/debug)

![iphone8debugad screenshot](/images/iphone8debugad.png)

Enter custom AdUnit Id.

![iphone8adunit screenshot](/images/iphone8adunit.png)

Use picker to select ad type.

![iphone8picker creenshot](/images/iphone8picker.png)

Example error message.

![iphone8error creenshot](/images/iphone8error.png)

Example interstitial ad.

![iphone8interstitial creenshot](/images/iphone8interstitial.png)

Add location data to ad request.

![iphone8location screenshot](/images/iphone8location.png)
