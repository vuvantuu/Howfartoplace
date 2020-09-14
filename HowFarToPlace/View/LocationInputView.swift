//
//  LocationInputView.swift
//  HowFarToPlace
//
//  Created by Vũ Tựu on 9/7/20.
//  Copyright © 2020 Vũ Tựu. All rights reserved.
//

import UIKit

protocol LocationInputViewDelegate : class{
    func dismissLocationInputView()
    func executeSearch(query: String)
}

class LocationInputView: UIView {
    //MARK: - Properties
    
    var user: User? {
        didSet {
            titleLabel.text = user?.fullname
        }
    }
     private var rideActionView = RideActionView()
    var delegate: LocationInputViewDelegate?
    let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        return button
    }()
     let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let startLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    let linkingView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    let destinationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    lazy var startingLocationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Current Location"
        tf.backgroundColor = .groupTableViewBackground
        tf.isEnabled = false
        tf.font = UIFont.systemFont(ofSize: 14)
        
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        tf.leftView = paddingView
        tf.leftViewMode = .always
        
        return tf
    }()
    
    lazy var destinationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter a destination.."
        tf.backgroundColor = UIColor.rgb(red: 215, green: 215, blue: 215)
        tf.returnKeyType = .search
        tf.font = UIFont.systemFont(ofSize: 14)
        let paddingView = UIView()
        tf.delegate = self
        paddingView.setDimensions(height: 30, width: 8)
        tf.leftView = paddingView
        tf.leftViewMode = .always
        //           tf.delegate = self
        tf.clearButtonMode = .whileEditing
        return tf
    }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(backButton)
        backButton.anchor(top: topAnchor, left: leftAnchor, paddingTop: 44, paddingLeft: 12, width:  24, height: 25)
        addSubview(titleLabel)
        titleLabel.centerY(inView: backButton)
        titleLabel.centerX(inView: self)
        
        addSubview(startingLocationTextField)
        startingLocationTextField.anchor(top: backButton.bottomAnchor, left: leftAnchor, right: rightAnchor,
                                         paddingTop: 4, paddingLeft: 40, paddingRight: 40, height: 30)
        
        addSubview(startLocationIndicatorView)
        startLocationIndicatorView.centerY(inView: startingLocationTextField, leftAnchor: leftAnchor, paddingLeft: 20)
        startLocationIndicatorView.setDimensions(height: 6, width: 6)
        startLocationIndicatorView.layer.cornerRadius = 6 / 2 // bo goc start icon
        
        addSubview(destinationTextField)
        destinationTextField.anchor(top: startingLocationTextField.bottomAnchor, left: leftAnchor,
                                    right: rightAnchor, paddingTop: 12, paddingLeft: 40,
                                    paddingRight: 40,height: 30)
        
        addSubview(destinationIndicatorView)
        destinationIndicatorView.centerY(inView: destinationTextField, leftAnchor: leftAnchor, paddingLeft: 20)
        destinationIndicatorView.setDimensions(height: 6, width: 6)
        
        addSubview(linkingView)
        linkingView.anchor(top: startLocationIndicatorView.bottomAnchor,
                           bottom: destinationIndicatorView.topAnchor, paddingTop: 4,
                           paddingLeft: 0, paddingBottom: 4, width: 0.5)
        linkingView.centerX(inView: startLocationIndicatorView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Selectors
    
    @objc func handleBackTapped(){
        rideActionView.alpha = 0
        delegate?.dismissLocationInputView()
    }
}
//MARK: - UITextFieldDelegate
extension LocationInputView: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else {return false}
        
        delegate?.executeSearch(query: query)
        return true
    }
}
