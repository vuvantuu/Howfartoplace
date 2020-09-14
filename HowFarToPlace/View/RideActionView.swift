//
//  rideActionView.swift
//  HowFarToPlace
//
//  Created by Vũ Tựu on 9/7/20.
//  Copyright © 2020 Vũ Tựu. All rights reserved.
//

import UIKit
import MapKit


protocol  RideActionViewDelegate: class {
    func uploadTrip(_ view: RideActionView)
}
class RideActionView: UIView {
    
    
    
     static let shared = RideActionView()
    
    //MARK: - Properties
    
    var destination: MKPlacemark? {
        didSet{
            titleLabel.text = destination?.name
            addressLabel.text = destination?.address
            
        }
    }
    
    weak var delegate: RideActionViewDelegate?
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    let addressLabel : UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    public var  distanceLabel : UILabel = {
       let label = UILabel()
       label.textColor = .black
       label.font = UIFont.systemFont(ofSize: 16)
       label.textAlignment = .center
       return label
   }()
    
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .green
        button.setTitle("CACULATE DISTANCE", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        distanceLabel.text = "press button below to get a distance"
        addShadow()
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel, distanceLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.centerX(inView : self)
        stack.anchor(top: topAnchor, paddingTop: 12)
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        addSubview(separatorView)
        
        separatorView.anchor(top: stack.bottomAnchor, left: leftAnchor,
                             right: rightAnchor, paddingTop: 4, height: 0.75)
        addSubview(actionButton)
               actionButton.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor,
               right: rightAnchor, paddingLeft: 12, paddingBottom: 0,paddingRight: 12, height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func actionButtonPressed(){
        print("DEBUG: ok")
        
        delegate?.uploadTrip(self)
        distanceLabel.text = Distance.distance
    }
}
