//
//  LoginController.swift
//  HowFarToPlace
//
//  Created by Vũ Tựu on 9/7/20.
//  Copyright © 2020 Vũ Tựu. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor =  .darkGray
        configUI()
    }
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
    private lazy var passContainer : UIView = {
        
        return UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passTF)
        
    }()
    
    private let passTF : UITextField = {
        return UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
    }()
    // MARK: - Selectors

    private let loginButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
                   button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button 
    }()
    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor(red: 0/255, green: 177/255, blue: 79/255, alpha: 1.0)]))
        
                   button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    // MARK: - Selectors
       
       @objc func handleLogin() {
           guard let email = emailTF.text else { return }
           guard let password = passTF.text else { return }

           Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
               if let error = error {
                   print("DEBUG: Failed to log user in with error \(error.localizedDescription)")
                   return
               }
            print("Login success")
//               guard let controller = UIApplication.shared.keyWindow?.rootViewController as? HomeController else { return }
//
//               controller.configure()
               self.dismiss(animated: true, completion: nil)
           }
       }
       
       @objc func handleShowSignUp() {
           let controller = SignUpController()
           navigationController?.pushViewController(controller, animated: true)
       }
    // MARK: - Helper
    
    func configUI() {
        configureNavigationBar()
        view.addSubview(logo)
        logo.anchor(top: view.topAnchor, paddingTop: 40, width: 100, height: 100)
        logo.centerX(inView: view)
        logo.loadimageFromURL(urlString: "https://freesvg.org/img/location_icon.png")
        
        let stack = UIStackView(arrangedSubviews: [emailContainer,
                                                   passContainer, loginButton ])
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(bottom: view.bottomAnchor, paddingBottom: 8)
        dontHaveAccountButton.centerX(inView: view)
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 24
        
        view.addSubview(stack)
        stack.anchor(top: logo.bottomAnchor, left: view.leftAnchor,
                     right: view.rightAnchor, paddingTop: 40, paddingLeft: 16,
                     paddingRight: 16)
    }
    func configureNavigationBar(){
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
}
