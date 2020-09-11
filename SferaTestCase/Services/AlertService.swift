//
//  AlertService.swift
//  SferaTestCase
//
//  Created by Anya on 10.09.2020.
//  Copyright © 2020 Anna Vondrukhova. All rights reserved.
//

import Foundation
import UIKit

class AlertService {
    
    static func showNetworkAlert(in vc: UIViewController, message: String) {
        let alertController = UIAlertController(title: "Network error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .destructive) { (_) in
            if let vc = vc as? UserListViewController {
                vc.activityIndicator.stopAnimating()
                vc.loadingView.isHidden = true
            } else if let vc = vc as? UserDetailsViewController {
                vc.profileView.configure(with: vc.user)
            }
        }
        alertController.addAction(okAction)
        
        vc.present(alertController, animated: true, completion: nil)

    }
    
}
