//
//  AuthButton.swift
//  HowFarToPlace
//
//  Created by Vũ Tựu on 9/7/20.
//  Copyright © 2020 Vũ Tựu. All rights reserved.
//

import UIKit

class AuthButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setTitleColor(UIColor(white: 1, alpha: 1), for: .normal)
        backgroundColor = UIColor(red: 0/255, green: 177/255, blue: 79/255, alpha: 1.0)
        layer.cornerRadius = 5
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
