//
//  User.swift
//  HowFarToPlace
//
//  Created by Vũ Tựu on 9/7/20.
//  Copyright © 2020 Vũ Tựu. All rights reserved.
//
import CoreLocation// get location info

enum AccountType: Int {
    case passenger
    case driver
}
struct User {
    let fullname: String
    let email: String
    var accountType: AccountType!
    var location: CLLocation?
    var uid: String
    
    
    init (uid: String, dictionary: [String: Any]){
        self.uid = uid
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
    
        if let index = dictionary["accountType"] as? Int {
            self.accountType = AccountType(rawValue: index)
        }
    }
}
