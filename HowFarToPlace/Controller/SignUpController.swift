//
//  SignUpController.swift
//  HowFarToPlace
//
//  Created by Vũ Tựu on 9/7/20.
//  Copyright © 2020 Vũ Tựu. All rights reserved.
//

import UIKit
import Firebase
import GeoFire

class SignUpController: UIViewController {
    
    let location = LocationHandler.shared.locationManager.location
    // MARK: - Properties
    private let logo : UIImageView = {
        let item = UIImageView()
        
        return item
    }()
    private lazy var emailContainer : UIView = {
        
        return UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTF)
        
    }()
    
    private let emailTF : UITextField = {
        return UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
    }()
    private lazy var fullnameContainer : UIView = {
        
        return UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: fullnameTF)
        
    }()
    
    private let fullnameTF : UITextField = {
        return UITextField().textField(withPlaceholder: "Fullname", isSecureTextEntry: false)
    }()
    private lazy var passContainer : UIView = {
        
        return UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passTF)
        
    }()
    
    private let passTF : UITextField = {
        return UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
    }()
//    private lazy var accountContainer : UIView = {
//
//        return UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_account_box_white_2x") , segmentedControl: accountTypeSegmentedControl)
//
//    }()
//
//    private let accountTypeSegmentedControl: UISegmentedControl = {
//           let sc = UISegmentedControl(items: ["Rider", "Driver"])
//           sc.backgroundColor =  UIColor(red: 0/255, green: 177/255, blue: 79/255, alpha: 1.0)
//           sc.tintColor = UIColor(white: 1, alpha: 0.87)
//           sc.selectedSegmentIndex = 0
//           return sc
//       }()
    // MARK: - Lifecycle
       override func viewDidLoad() {
           super.viewDidLoad()
           view.backgroundColor =  .darkGray
        
           configUI()

           print("DEBUG: Location is \(location)")
       }
    // MARK: - Selectors
    
    private let signupButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
                   button.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        return button
    }()
    let haveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor(red: 0/255, green: 177/255, blue: 79/255, alpha: 1.0)]))
        
        button.addTarget(self, action: #selector(handleShowSignIn), for: .touchUpInside)
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    // MARK: - Selectors
    
           @objc func handleSignup() {
               guard let email = emailTF.text else { return }
               guard let password = passTF.text else { return }
               guard let fullname = fullnameTF.text else { return }
                
               Auth.auth().createUser(withEmail: email, password: password){ (result, error) in
                   if let error = error {
                    print("DEBUG: Failed to rigister user in with error \(error.localizedDescription)")
                       return
                   }
    
                guard let uid = result?.user.uid else {return}
                
                
                
                let values = ["email": email,
                              "fullname": fullname] as [String : Any]
                
                
                
                self.uploadUserdataAndDismiss(uid: uid, values: values)
                self.dismiss(animated: true, completion: nil)
               }
            
           }
    
    @objc func handleShowSignIn() {
        navigationController?.popViewController( animated: true)
    }
    // MARK: - Helper
    
    func uploadUserdataAndDismiss(uid: String, values: [String: Any]){
        REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: {
            (error, ref) in
            guard let controller = UIApplication.shared.keyWindow?.rootViewController as?
                HomeController else {return}
            controller.configure()
             
        })
    }
    func configUI() {
        view.addSubview(logo)
        logo.anchor(top: view.topAnchor, paddingTop: 40, width: 100, height: 100)
        logo.centerX(inView: view)
        logo.loadimageFromURL(urlString: "https://freesvg.org/img/location_icon.png")
        
        let stack = UIStackView(arrangedSubviews: [emailContainer,
                                                   fullnameContainer,passContainer, signupButton ])
        view.addSubview(haveAccountButton)
        haveAccountButton.anchor(bottom: view.bottomAnchor, paddingBottom: 8)
        haveAccountButton.centerX(inView: view)
        
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 24
        
        view.addSubview(stack)
        stack.anchor(top: logo.bottomAnchor, left: view.leftAnchor,
                     right: view.rightAnchor, paddingTop: 40, paddingLeft: 16,
                     paddingRight: 16)
    }
    
}
