//
//  ViewController.swift
//  ViewDFPAds
//
import GoogleMobileAds
import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, UIScrollViewDelegate, GADBannerViewDelegate, GADAdSizeDelegate, GADInterstitialDelegate {

    //MARK: Properties
    @IBOutlet weak var adUnitTextField: UITextField?
    @IBOutlet weak var displayAdButton: UIButton?
    @IBOutlet weak var adPicker: UIPickerView?
    @IBOutlet weak var addLocationSwitch: UISwitch?
    @IBOutlet weak var addLocationValuesLabel: UILabel?
    @IBOutlet weak var adResponseScrollView: UIScrollView?
    
    //MARK: Actions
    @IBAction func getDisplayAd(_ sender: UIButton) {
        adResponseScrollViewClear()
        if (adPickerSelected == Constants.Empty) {
            return
        }
        if (adPickerSelected == Constants.Interstitial) {
            adUnitID = getAdUnitID(adPickerValue: adPickerSelected)
            createAndLoadInterstitial(adUnitID: adUnitID)
            return
        }
        createAndLoadBanner()
    }
    
    @IBAction func openDebugOptions(_ sender: UIButton) {
        let debugOptionsViewController = GADDebugOptionsViewController(adUnitID: "/7231/today")
        self.present(debugOptionsViewController, animated: true, completion: nil)
    }
    
    //MARK: locals
    var adPickerData: [String] = [String]()
    var adPickerSelected: String = Constants.Empty
    var bannerView: DFPBannerView?
    var interstitial: DFPInterstitial?
    var locationManager = CLLocationManager()
    var location: CLLocation? = nil
    var adUnitID = Constants.DFPAdSizesAdUnitID
    var adErrorLabel: UILabel?
    var msgLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Google Mobile Ads SDK version: \(DFPRequest.sdkVersion())")
        
        initLabels()
        initAdUnitTextField()
        initBannerView()
        initAdPicker()
        initScrollView()
        initLocation()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK: initializations
    private func initLabels() {
        adErrorLabel = UILabel()
        msgLabel = UILabel()
    }
    
    private func initAdUnitTextField() {
        if let adUnitTextField = adUnitTextField {
            updateAdUnitTextFieldPlaceholder()
            adUnitTextField.delegate = self
        }
    }
    
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
        for adPickerValue in Constants.AdPickerDictionaryLiteral {
            adPickerData.append(adPickerValue.key)
        }
        print("adPickerData: \(adPickerData)")
        adPickerSelected = adPickerData[0]
    }
    
    private func initScrollView() {
        if let adResponseScrollView = adResponseScrollView {
            adResponseScrollView.delegate = self
        }
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
    
    private func updateAdUnitTextFieldPlaceholder() {
        if let adUnitTextField = adUnitTextField {
            if (adPickerSelected == Constants.Interstitial) {
                adUnitTextField.placeholder = Constants.DFPInterstitialAdUnitID
            } else {
                adUnitTextField.placeholder = Constants.DFPAdSizesAdUnitID
            }
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
    
    private func adResponseScrollViewClear() {
        if let adResponseScrollView = adResponseScrollView {
            for view in adResponseScrollView.subviews{
                view.removeFromSuperview()
            }
        }
    }
    
    //MARK: AdErrorLabel helpers
    private func showAdErrorLabel(description: String) {
        guard let adResponseScrollView = adResponseScrollView else {
            return
        }
        guard let adErrorLabel = adErrorLabel else {
            return
        }
        if let bannerView = bannerView {
            bannerView.removeFromSuperview()
        }
        adResponseScrollView.addSubview(adErrorLabel)
        adErrorLabel.text = description
        adErrorLabel.numberOfLines = 0
        adErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        let guide = adResponseScrollView.safeAreaLayoutGuide
        NSLayoutConstraint.activate([guide.topAnchor.constraint(equalTo: adErrorLabel.topAnchor, constant: -5),
                                     guide.centerXAnchor.constraintEqualToSystemSpacingAfter(adErrorLabel.centerXAnchor, multiplier: 1.0),
                                     guide.leftAnchor.constraint(equalTo: adErrorLabel.leftAnchor, constant: -15),
                                     guide.rightAnchor.constraint(equalTo: adErrorLabel.rightAnchor, constant: 15)])
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
        interstitial = DFPInterstitial(adUnitID: adUnitID)
        if let interstitial = interstitial {
            interstitial.delegate = self
            let request = getDFPRequest()
            interstitial.load(request)
        }
    }
    
    private func getAdSizes(adPickerValue: String) -> [NSValue] {
        var adSizes = [NSValue]()
        for adPickerValue in Constants.AdPickerDictionaryLiteral {
            if (adPickerSelected == adPickerValue.key) {
                adSizes = adPickerValue.value
                break
            }
        }
        return adSizes
    }
    
    private func createAndLoadBanner() {
        guard let bannerView = bannerView else {
           return
        }
        let adSizes = getAdSizes(adPickerValue: adPickerSelected)
        adUnitID = getAdUnitID(adPickerValue: adPickerSelected)
        bannerView.adUnitID = adUnitID
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
        updateAdUnitTextFieldPlaceholder()
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        adUnitID = getAdUnitID(adPickerValue: adPickerSelected)
    }
    
    //MARK: Location delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locationsLast = locations.last {
            location = locationsLast as CLLocation
        }
    }
    
    //MARK: UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        var height: CGFloat = 0
        if let bannerView = bannerView {
            print("bannerViewSize: \(bannerView.bounds.size)")
            height += bannerView.bounds.height
        }
        if let msgLabel = msgLabel {
            print("msgLabelSize: \(msgLabel.bounds.size)")
            height += msgLabel.bounds.size.height
        }
        if let adResponseScrollView = adResponseScrollView {
            if (height > (adResponseScrollView.bounds.height + 100)) {
                scrollView.contentSize.height = height
            }
        }
    }
    
    private func addMessageToAdResponseView(msg: String, adResponseView: UIView, msgLabelTopAnchor: NSLayoutYAxisAnchor) {
        if let msgLabel = msgLabel {
            msgLabel.text = msg
            msgLabel.textAlignment = NSTextAlignment.left
            msgLabel.numberOfLines = 0
            msgLabel.translatesAutoresizingMaskIntoConstraints = false
            adResponseView.addSubview(msgLabel)
            let guide = adResponseView.safeAreaLayoutGuide
            NSLayoutConstraint.activate([msgLabelTopAnchor.constraint(equalTo: msgLabel.topAnchor, constant: -5),
                                         guide.centerXAnchor.constraintEqualToSystemSpacingAfter(msgLabel.centerXAnchor, multiplier: 1.0),
                                         guide.leftAnchor.constraint(equalTo: msgLabel.leftAnchor, constant: -15),
                                         guide.rightAnchor.constraint(equalTo: msgLabel.rightAnchor, constant: 15)])
            
            print("msgLabel: \(msgLabel.bounds.size)")
            print("adResponseView: \(adResponseView.bounds.size)")
        }
    }
    
    private func adResponseScrollViewUpdate(adResponseView: UIView) {
        if let adResponseScrollView = adResponseScrollView {
            adResponseScrollView.contentOffset = CGPoint.zero
            adResponseView.frame = adResponseScrollView.bounds
            adResponseScrollView.contentSize = adResponseView.bounds.size
            adResponseScrollView.contentSize.height = adResponseScrollView.bounds.height + 100
            adResponseScrollView.autoresizingMask = UIViewAutoresizing.flexibleHeight
            adResponseScrollView.addSubview(adResponseView)
            print("adResponseScrollView: \(adResponseScrollView.bounds.size)")
        }
    }
    
    //MARK: GADBannerViewDelegate
    // Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd: \(bannerView)")
        let adResponseView = UIView()
        adResponseView.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        let guide = adResponseView.safeAreaLayoutGuide
        NSLayoutConstraint.activate([guide.topAnchor.constraint(equalTo: bannerView.topAnchor, constant: -5),
                                     guide.centerXAnchor.constraintEqualToSystemSpacingAfter(bannerView.centerXAnchor, multiplier: 1.0)])
        var msg = "";
        if let adUnitId = bannerView.adUnitID {
            msg += "\nadUnitId: \(adUnitId)"
        }
        msg += "\nadSize: \(bannerView.adSize.size)"
        if let adNetworkClassname = bannerView.adNetworkClassName {
            msg += "\nadNetworkClassName: \(adNetworkClassname)"
        }
        addMessageToAdResponseView(msg: msg, adResponseView: adResponseView, msgLabelTopAnchor: bannerView.bottomAnchor)
        adResponseScrollViewUpdate(adResponseView: adResponseView)
    }
    
    // Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        showAdErrorLabel(description: error.localizedDescription)
    }
    
    // MARK: GADAdSizeDelegate
    /// Called before the ad view changes to the new size.
    func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
        // The bannerView calls this method on its adSizeDelegate object before the banner updates its
        // size, allowing the application to adjust any views that may be affected by the new ad size.
        print("Make your app layout changes here, if necessary. New banner ad size will be \(size).")
    }
    
    //MARK: GADInterstitialDelegate
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        if let interstitial = interstitial {
            if (interstitial.isReady) {
                interstitial.present(fromRootViewController: self)
                if let bannerView = bannerView {
                    bannerView.removeFromSuperview()
                }
                let adResponseView = UIView()
                let guide = adResponseView.safeAreaLayoutGuide
                var msg = "";
                msg += "\nadUnitId: \(interstitial.adUnitID)"
                if let correlator = interstitial.correlator {
                    msg += "\ncorrelator: \(correlator)"
                }
                if let adNetworkClassname = interstitial.adNetworkClassName {
                    msg += "\nadNetworkClassName: \(adNetworkClassname)"
                }
                addMessageToAdResponseView(msg: msg, adResponseView: adResponseView, msgLabelTopAnchor: guide.topAnchor)
                adResponseScrollViewUpdate(adResponseView: adResponseView)
            }
        }
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        showAdErrorLabel(description: error.localizedDescription)
    }
}
