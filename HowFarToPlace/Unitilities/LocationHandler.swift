//
//  LocationHandler.swift
//  HowFarToPlace
//
//  Created by Vũ Tựu on 9/7/20.
//  Copyright © 2020 Vũ Tựu. All rights reserved.
//
import CoreLocation

class LocationHandler: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationHandler()
    var locationManager: CLLocationManager!
    var location: CLLocation?
    // Add two variables to store lat and long
    var lat = 0.0
    var long = 0.0
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        if status == .authorizedWhenInUse {
//            locationManager.requestAlwaysAuthorization()
//        }
//    }
    // To get the location for the user
      func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
          let location:CLLocationCoordinate2D = manager.location!.coordinate
          lat = location.latitude
          long = location.longitude
      }
}

    

