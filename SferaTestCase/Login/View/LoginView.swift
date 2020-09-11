//
//  LoginView.swift
//  SferaTestCase
//
//  Created by Anya on 11.09.2020.
//  Copyright © 2020 Anna Vondrukhova. All rights reserved.
//

import UIKit

protocol LoginViewDelegate {
    func showAlert(message: String)
}

class LoginView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var loginTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    var delegate: LoginViewController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
    }
    
    private func customInit() {
        Bundle.main.loadNibNamed("LoginView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.layer.cornerRadius = 10.0
        contentView.layer.borderWidth = 3.0
        contentView.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.cornerRadius = 5.0
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        delegate.activityIndicator.startAnimating()
        UserDefaults.standard.set(self.loginTextField.text, forKey: "login")
        UserDefaults.standard.set(self.passwordTextField.text, forKey: "password")
        
        let url = URL(string: "https://api.github.com/user")
        
        NetworkService.shared.getData(with: url!) { (data, statusCode) in
            if statusCode == 200 {
                UserDefaults.standard.set(true, forKey: "isAuthorized")
                
                DispatchQueue.main.async {
                    self.delegate.activityIndicator.stopAnimating()
                    self.delegate.dismiss(animated: true, completion: nil)
                }
            } else {
                var message = ""
                
                switch statusCode {
                case URLError.Code.notConnectedToInternet.rawValue:
                    message = "No internet connection"
                case URLError.Code.timedOut.rawValue:
                    message = "No internet connection"
                case 401:
                    message = "Invalid login or password"
                default:
                    message = "Server is not responding"
                }
                DispatchQueue.main.async {
                    self.delegate.activityIndicator.stopAnimating()
                    self.delegate.showAlert(message: message)
                }
            }
        }
    }
    @IBAction func continueButtonPressed(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isAuthorized")
        UserDefaults.standard.set(nil, forKey: "login")
        UserDefaults.standard.set(nil, forKey: "password")
        delegate.dismiss(animated: true, completion: nil)
    }
    
}
