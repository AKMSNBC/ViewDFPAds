//
//  DFPAdsModel.swift
//  ViewDFPAds
//

import Foundation
import CoreLocation

class DFPAdsModel: NSObject, CLLocationManagerDelegate {
    
    private var locationManager = CLLocationManager()
    private var location: CLLocation? = nil
    
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
            location = locationsLast as CLLocation
        }
    }
    
    func getLocation() -> CLLocation? {
        if let location = location {
            return location
        }
        return nil
    }
}
