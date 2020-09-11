//
//  UserDetailsService.swift
//  SferaTestCase
//
//  Created by Anya on 09.09.2020.
//  Copyright © 2020 Anna Vondrukhova. All rights reserved.
//

import Foundation

protocol UserDetailsServiceDelegate {
    func showAlert(message: String)
}

class UserDetailsService {
    static let shared = UserDetailsService()
    var delegate: UserDetailsViewController!
        
    func getUserDetails(user: User, completion: @escaping (User) -> ()) {
        guard let url = URL(string: "https://api.github.com/users/\(user.login.lowercased())") else {
            completion(user)
            return
        }
        
        NetworkService.shared.getData(with: url) { (data, statusCode) in
            guard let data = data, statusCode == 200 else {
                completion(user)
                var message = ""
                
                switch statusCode {
                case URLError.Code.notConnectedToInternet.rawValue:
                    message = "No internet connection"
                case URLError.Code.timedOut.rawValue:
                    message = "No internet connection"
                case 403:
                    message = "Authentication error"
                default:
                    message = "Server is not responding"
                }
                DispatchQueue.main.async {
                    self.delegate.showAlert(message: message)
                }
                return
            }
            
            var configuredUser = user
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                guard let json = jsonObject as? [String: Any] else {
                    completion(configuredUser)
                    return print("Invalid JSON")
                }
                
                configuredUser.configure(with: json)
                DispatchQueue.main.async {
                    completion(configuredUser)
                }
            } catch {
                completion(configuredUser)
                print("JSON parsing error: " + error.localizedDescription)
            }
            
        }
    }

}
