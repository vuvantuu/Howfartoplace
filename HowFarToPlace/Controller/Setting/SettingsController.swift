//
//  SettingsController.swift
//  HowFarToPlace
//
//  Created by Vũ Tựu on 9/7/20.
//  Copyright © 2020 Vũ Tựu. All rights reserved.
//

import UIKit


enum LocationType: Int, CaseIterable, CustomStringConvertible {
    case home
    case work
    
    var description: String {
        switch self {
        case .home: return "Home"
        case .work: return "Work"
        }
    }
    
    var subtitle: String {
        switch self {
        case .home: return "Add Home"
        case .work: return "Add Work"
        }
    }
}
