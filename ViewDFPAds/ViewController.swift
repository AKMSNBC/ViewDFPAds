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
    @IBOutlet weak var adPicker: UIPickerView?
    @IBOutlet weak var addLocationSwitch: UISwitch?
    @IBOutlet weak var addLocationValuesLabel: UILabel?
    @IBOutlet weak var adErrorLabel: UILabel?
    
    var adPickerData: [String] = [String]()
    var adPickerSelected: String = Constants.Empty
    var bannerView: DFPBannerView?
    var interstitial: DFPInterstitial?
    var locationManager = CLLocationManager()
    var location: CLLocation? = nil
    var adUnitID = Constants.DFPAdSizesAdUnitID
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Google Mobile Ads SDK version: \(DFPRequest.sdkVersion())")
        
        hideAdErrorLabel()
        if let adUnitTextField = adUnitTextField {
            adUnitTextField.delegate = self
        }
        updateAdUnitIDLabel(adUnitIDValue: adUnitID)
        initBannerView()
        initAdPicker()
        initLocation()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK: locals
    private func initBannerView() {
        bannerView = DFPBannerView(adSize: kGADAdSizeBanner)
        if let bannerView = bannerView {
            bannerView.adUnitID = adUnitID
            bannerView.rootViewController = self
            bannerView.adSizeDelegate = self
            bannerView.delegate = self
        }
    }
    
    private func initAdPicker() {
        if let adPicker = adPicker {
            adPicker.delegate = self
            adPicker.dataSource = self
        }
        adPickerData = ["Multi", "300x250", "320x50", "120x20 Custom", "Interstitial"]
        adPickerSelected = adPickerData[0]
    }
    
    private func initLocation() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        if let addLocationSwitch = addLocationSwitch {
            addLocationSwitch.addTarget(self, action: #selector(switchChanged), for: UIControlEvents.valueChanged)
        }
    }
    
    @objc private func switchChanged(sender: UISwitch) {
        updateAddLocationValuesLabel()
    }
    
    private func getAdUnitID (adPickerValue: String) -> String {
        var adUnitId = Constants.DFPAdSizesAdUnitID
        if (adPickerValue == Constants.Interstitial) {
            adUnitId = Constants.DFPInterstitialAdUnitID
        }
        guard let adUnitTextField = adUnitTextField else {
            return adUnitId
        }
        guard let adUnitTextFieldText = adUnitTextField.text else {
            return adUnitId
        }
        if (adUnitTextFieldText.isEmpty == false) {
            return adUnitTextFieldText
        }
        return adUnitId
    }
    
    private func getDFPRequest() -> DFPRequest {
        let request = DFPRequest()
        if let addLocationSwitch = addLocationSwitch {
            if (addLocationSwitch.isOn) {
                if let location = location {
                    if (CLLocationManager.locationServicesEnabled()) {
                        request.setLocationWithLatitude(CGFloat(location.coordinate.latitude), longitude: CGFloat(location.coordinate.latitude), accuracy: 100)
                        updateAddLocationValuesLabel()
                    } else {
                        updateAddLocationValuesLabel(message: Constants.ServiceDisabled)
                    }
                }
            }
        }
        print("request \(request.debugDescription)")
        return request
    }
    
    private func updateAdUnitIDLabel(adUnitIDValue: String) {
        print("adUnitID: \(adUnitIDValue)")
        if let adUnitLabel = adUnitLabel {
            adUnitLabel.text = "adUnitID: \(adUnitIDValue)"
        }
    }
    
    //MARK: AdErrorLabel helpers
    private func hideAdErrorLabel() {
        updateAdErrorLabel(isHidden: true, description: Constants.Empty)
    }
    
    private func showAdErrorLabel(description: String) {
        updateAdErrorLabel(isHidden: false, description: description)
    }
    
    private func updateAdErrorLabel(isHidden: Bool, description: String) {
        if let adErrorLabel = adErrorLabel {
            if (isHidden == true) {
                adErrorLabel.isHidden = true
                return
            }
            print("adView:didFailToReceiveAdWithError: \(description)")
            if let bannerView = bannerView {
                bannerView.removeFromSuperview()
            }
            adErrorLabel.isHidden = false
            adErrorLabel.text = description
            return
        }
    }
    
    private func updateAddLocationValuesLabel(message: String) {
        if let addLocationValuesLabel = addLocationValuesLabel {
            addLocationValuesLabel.text = message
        }
    }
    
    private func updateAddLocationValuesLabel() {
        updateAddLocationValuesLabel(message: Constants.Empty)
        guard let addLocationSwitch = addLocationSwitch else {
            return
        }
        guard let location = location else {
            return
        }
        if (addLocationSwitch.isOn){
            let message = "\(location.coordinate.latitude.description), \(location.coordinate.longitude.description)"
            updateAddLocationValuesLabel(message: message)
        }
    }
    
    private func createAndLoadInterstitial(adUnitID: String) {
        hideAdErrorLabel()
        interstitial = DFPInterstitial(adUnitID: adUnitID)
        if let interstitial = interstitial {
            interstitial.delegate = self
            let request = getDFPRequest()
            interstitial.load(request)
        }
    }
    
    private func createAndLoadBanner() {
        guard let bannerView = bannerView else {
           return
        }
        
        var adSizes = [NSValue]()
        
        if (adPickerSelected == "Multi" || adPickerSelected == "120x20 Custom") {
            let customGADAdSize = GADAdSizeFromCGSize(CGSize(width: 120, height: 20))
            adSizes.append(NSValueFromGADAdSize(customGADAdSize))
        }
        if (adPickerSelected == "Multi" || adPickerSelected == "320x50") {
            adSizes.append(NSValueFromGADAdSize(kGADAdSizeBanner))
        }
        if (adPickerSelected == "Multi" || adPickerSelected == "300x250") {
            adSizes.append(NSValueFromGADAdSize(kGADAdSizeMediumRectangle))
        }
        
        adUnitID = getAdUnitID(adPickerValue: adPickerSelected)
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
        adUnitID = getAdUnitID(adPickerValue: adPickerSelected)
        updateAdUnitIDLabel(adUnitIDValue: adUnitID)
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let displayAdButton = displayAdButton {
            displayAdButton.isHidden = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let displayAdButton = displayAdButton {
            displayAdButton.isHidden = false
        }
        adUnitID = getAdUnitID(adPickerValue: adPickerSelected)
        updateAdUnitIDLabel(adUnitIDValue: adUnitID)
    }
    
    //MARK: Actions
    @IBAction func getDisplayAd(_ sender: UIButton) {
        if (adPickerSelected == Constants.Empty) {
            return
        }
        if (adPickerSelected == Constants.Interstitial) {
            adUnitID = getAdUnitID(adPickerValue: adPickerSelected)
            createAndLoadInterstitial(adUnitID: adUnitID)
            updateAdUnitIDLabel(adUnitIDValue: adUnitID)
            return
        }
        createAndLoadBanner()
    }
    
    //MARK: Location delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locationsLast = locations.last {
            location = locationsLast as CLLocation
        }
    }
    
    //MARK: GADBannerViewDelegate
    // Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        hideAdErrorLabel()
        view.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([guide.bottomAnchor.constraintEqualToSystemSpacingBelow(bannerView.bottomAnchor, multiplier: 1.0),
                                     guide.centerXAnchor.constraintEqualToSystemSpacingAfter(bannerView.centerXAnchor, multiplier: 1.0)])
    }
    
    // Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        showAdErrorLabel(description: error.localizedDescription)
    }

    //MARK: GADInterstitialDelegate
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        if let interstitial = interstitial {
            if (interstitial.isReady) {
                interstitial.present(fromRootViewController: self)
            }
        }
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        showAdErrorLabel(description: error.localizedDescription)
    }
    
    // MARK: GADAdSizeDelegate
    /// Called before the ad view changes to the new size.
    func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
        // The bannerView calls this method on its adSizeDelegate object before the banner updates its
        // size, allowing the application to adjust any views that may be affected by the new ad size.
        print("Make your app layout changes here, if necessary. New banner ad size will be \(size).")
    }
    
}
