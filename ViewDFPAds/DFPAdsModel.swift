//
//  DFPAdsModel.swift
//  ViewDFPAds
//

import Foundation
import GoogleMobileAds
import CoreLocation

class DFPAdsModel: NSObject, CLLocationManagerDelegate {
    
    private var locationManager = CLLocationManager()
    private var _location: CLLocation? = nil
    
    static let singletonInstance = DFPAdsModel()
    
    var isAddLocation: Bool = false
    var location: CLLocation? {
        return _location
    }
    var adUnitID: String = Constants.DFPAdSizesAdUnitID
    
    override init() {
        super.init()
        if (CLLocationManager.locationServicesEnabled()) {
            initLocation()
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
    }
    
    //MARK: Location delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locationsLast = locations.last {
            _location = locationsLast as CLLocation
        }
    }
    
    func getDFPRequest() -> DFPRequest {
        let request = DFPRequest()
        if (isAddLocation == true) {
            if let location = location {
                request.setLocationWithLatitude(CGFloat(location.coordinate.latitude), longitude: CGFloat(location.coordinate.latitude), accuracy: 100)
                print("added location: \(location.coordinate)")
            }
        }
        print("request \(request.debugDescription)")
        return request
    }
}
