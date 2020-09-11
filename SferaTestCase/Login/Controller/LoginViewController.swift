//
//  LoginViewController.swift
//  SferaTestCase
//
//  Created by Anya on 11.09.2020.
//  Copyright © 2020 Anna Vondrukhova. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet var loginView: LoginView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginView.layer.cornerRadius = 10.0
        loginView.delegate = self
        
        activityIndicator.hidesWhenStopped = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

extension LoginViewController: LoginViewDelegate {
    func showAlert(message: String) {
        AlertService.showNetworkAlert(in: self, message: message)
    }
    
    
}
