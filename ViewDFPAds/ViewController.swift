//
//  ViewController.swift
//  ViewDFPAds
//
import GoogleMobileAds
import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, GADBannerViewDelegate, GADAdSizeDelegate, GADInterstitialDelegate {

    //MARK: Properties
    @IBOutlet weak var adUnitTextField: UITextField?
    @IBOutlet weak var displayAdButton: UIButton?
    @IBOutlet weak var adUnitLabel: UILabel?
    @IBOutlet weak var adPicker: UIPickerView!
    @IBOutlet weak var addLocationSwitch: UISwitch!
    @IBOutlet weak var addLocationLabel: UILabel!
    @IBOutlet weak var adErrorLabel: UILabel!
    
    var adPickerData: [String] = [String]()
    var adPickerSelected: String? = nil
    var bannerView: DFPBannerView!
    var interstitial: DFPInterstitial!
    var locationManager = CLLocationManager()
    var location: CLLocation? = nil
    var adUnitID = Constants.DFPAdSizesAdUnitID
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Google Mobile Ads SDK version: \(DFPRequest.sdkVersion())")
        
        adErrorLabel.isHidden = true
        if let adUnitTextField = adUnitTextField {
            adUnitTextField.delegate = self
        }
        updateAdUnitIDLabel(adUnitIDValue: adUnitID)
        initBannerView()
        initAdPicker()
        initLocation()
    }
    
    //MARK: locals
    fileprivate func initBannerView() {
        bannerView = DFPBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = self
        bannerView.adSizeDelegate = self
        bannerView.delegate = self
    }
    
    fileprivate func initAdPicker() {
        adPicker.delegate = self
        adPicker.dataSource = self
        adPickerData = ["Multi", "300x250", "320x50", "120x20 Custom", "Interstitial"]
        adPickerSelected = adPickerData[0]
    }
    
    fileprivate func initLocation() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        addLocationSwitch.addTarget(self, action: #selector(switchChanged), for: UIControlEvents.valueChanged)
    }
    
    @objc fileprivate func switchChanged(sender: UISwitch) {
        updateAddLocationLabel()
    }
    
    fileprivate func getAdUnitID (adPickerValue: String) -> String {
        if let adUnitTextField = adUnitTextField {
            if let adUnitText = adUnitTextField.text {
                if (adUnitText.isEmpty == false) {
                    return adUnitText
                }
            }
        }
        if (adPickerValue == Constants.Interstitial) {
            return Constants.DFPInterstitialAdUnitID
        }
        return Constants.DFPAdSizesAdUnitID
    }
    
    fileprivate func getDFPRequest() -> DFPRequest {
        let request = DFPRequest()
        
        if (addLocationSwitch.isOn && location != nil) {
            if (CLLocationManager.locationServicesEnabled()) {
                request.setLocationWithLatitude(CGFloat(location!.coordinate.latitude), longitude: CGFloat(location!.coordinate.latitude), accuracy: 100)
                updateAddLocationLabel()
            } else {
                addLocationLabel.text = "Location Service Disabled"
            }
        }
        print("request \(request.debugDescription)")
        return request
    }
    
    fileprivate func updateAdUnitIDLabel(adUnitIDValue: String) {
        print("adUnitID: \(adUnitIDValue)")
        if let adUnitLabel = adUnitLabel {
            adUnitLabel.text = "adUnitID: \(adUnitIDValue)"
        }
    }
    
    fileprivate func updateAdErrorLabel(description: String) {
        print("adView:didFailToReceiveAdWithError: \(description)")
        bannerView.removeFromSuperview()
        adErrorLabel.isHidden = false
        adErrorLabel.text = description
    }
    
    fileprivate func updateAddLocationLabel(){
        if (addLocationSwitch.isOn && location != nil){
            addLocationLabel.text = "Add Location: \(location!.coordinate.latitude.description), \(location!.coordinate.longitude.description)"
        } else {
            addLocationLabel.text = "Add Location:"
        }
    }
    
    fileprivate func createAndLoadInterstitial(adUnitID: String) {
        adErrorLabel.isHidden = true
        interstitial = DFPInterstitial(adUnitID: adUnitID)
        interstitial.delegate = self
        let request = getDFPRequest()
        interstitial.load(request)
    }
    
    fileprivate func createAndLoadBanner() {
        var adSizes = [NSValue]()
        
        if (adPickerSelected! == "Multi" || adPickerSelected! == "120x20 Custom") {
            let customGADAdSize = GADAdSizeFromCGSize(CGSize(width: 120, height: 20))
            adSizes.append(NSValueFromGADAdSize(customGADAdSize))
        }
        if (adPickerSelected! == "Multi" || adPickerSelected! == "320x50") {
            adSizes.append(NSValueFromGADAdSize(kGADAdSizeBanner))
        }
        if (adPickerSelected! == "Multi" || adPickerSelected! == "300x250") {
            adSizes.append(NSValueFromGADAdSize(kGADAdSizeMediumRectangle))
        }
        
        adUnitID = getAdUnitID(adPickerValue: adPickerSelected!)
        bannerView.adUnitID = adUnitID
        updateAdUnitIDLabel(adUnitIDValue: adUnitID)
        bannerView.validAdSizes = adSizes
        
        let request = getDFPRequest()
        bannerView.load(request)
    }
    
    //MARK: Picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return adPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return adPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        adPickerSelected = adPickerData[row]
        adUnitID = getAdUnitID(adPickerValue: adPickerSelected!)
        updateAdUnitIDLabel(adUnitIDValue: adUnitID)
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let displayAdButton = displayAdButton {
            displayAdButton.isHidden = true;
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let displayAdButton = displayAdButton {
            displayAdButton.isHidden = false;
        }
        adUnitID = getAdUnitID(adPickerValue: adPickerSelected!)
        updateAdUnitIDLabel(adUnitIDValue: adUnitID)
    }
    
    //MARK: Actions
    @IBAction func getDisplayAd(_ sender: UIButton) {
        
        if (adPickerSelected == nil) {
            return
        }
        
        if (adPickerSelected! == "Interstitial") {
            adUnitID = getAdUnitID(adPickerValue: adPickerSelected!)
            createAndLoadInterstitial(adUnitID: adUnitID)
            updateAdUnitIDLabel(adUnitIDValue: adUnitID)
            return
        }
        
        createAndLoadBanner()
    }
    
    //MARK: Location delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last! as CLLocation
    }
    
    //MARK: GADBannerViewDelegate
    // Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        adErrorLabel.isHidden = true
        view.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout constraints that align the banner view to the bottom center of the screen.
        view.addConstraint(NSLayoutConstraint(item: bannerView, attribute: .bottom, relatedBy: .equal,
                                              toItem: bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView, attribute: .centerX, relatedBy: .equal,
                                              toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    // Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        updateAdErrorLabel(description: error.localizedDescription)
    }

    //MARK: GADInterstitialDelegate
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        if (interstitial.isReady) {
            interstitial.present(fromRootViewController: self)
        }
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        updateAdErrorLabel(description: error.localizedDescription)
    }
    
    // MARK: GADAdSizeDelegate
    /// Called before the ad view changes to the new size.
    func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
        // The bannerView calls this method on its adSizeDelegate object before the banner updates its
        // size, allowing the application to adjust any views that may be affected by the new ad size.
        print("Make your app layout changes here, if necessary. New banner ad size will be \(size).")
    }
    
}
