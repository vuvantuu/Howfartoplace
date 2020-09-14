//
//  Services.swift
//  HowFarToPlace
//
//  Created by Vũ Tựu on 9/7/20.
//  Copyright © 2020 Vũ Tựu. All rights reserved.
//

import Firebase
import CoreLocation
import GeoFire

// MARK: - DatabaseRefs

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")
let REF_TRIPS = DB_REF.child("trips")

struct Service {
    
    static let shared = Service()
    func fetchUserData(uid: String, completion: @escaping(User) -> Void){
        
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            print("DEBUG: User email is \(user.email)")
            print("DEBUG: User fullname is \(user.fullname)")
            print("DEBUG: User accountType is \(user.accountType)")
           
        }
    }
     func fetchDrivers(location: CLLocation, completion: @escaping(User) -> Void) {
        
          let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
           
          REF_DRIVER_LOCATIONS.observe(.value) { (snapshot) in
            
              geofire.query(at: location, withRadius: 50).observe(.keyEntered, with: { (uid, location) in
                  Service.shared.fetchUserData(uid: uid, completion: { user in
                      var driver = user
                      driver.location = location
                    print("DEBUG: User djb djgcdgv")
                      completion(driver)
                  })
              })
          }
      }
    func uploadTrip(_ pickupCoordinates: CLLocationCoordinate2D, _ destinationCoordinates: CLLocationCoordinate2D, completion: @escaping(Error?, DatabaseReference) -> Void){
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let pickupArray = [pickupCoordinates.latitude, pickupCoordinates.longitude]
        
        let destinationArray = [destinationCoordinates.latitude, destinationCoordinates.longitude]
       
        let values = ["pickupCoordinates": pickupArray,
                             "destinationCoordinates": destinationArray,
                             "state": TripState.requested.rawValue] as [String : Any]
        REF_TRIPS.child(uid).updateChildValues(values, withCompletionBlock: completion)
        
    }
}
