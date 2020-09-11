//
//  UserDetailsService.swift
//  SferaTestCase
//
//  Created by Anya on 09.09.2020.
//  Copyright © 2020 Anna Vondrukhova. All rights reserved.
//

import Foundation

class UserDetailsService {
    static let shared = UserDetailsService()
        
    func getUserProfile(user: User, completion: @escaping (User) -> ()) {
        guard let url = URL(string: "https://api.github.com/users/\(user.login)") else {
            completion(user)
            return
        }
        
        NetworkService.shared.getData(with: url) { (data) in
            var configuredUser = user
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                guard let json = jsonObject as? [String: Any] else {
                    completion(configuredUser)
                    return print("Invalid JSON")
                }
                
                configuredUser.configure(with: json)
                completion(configuredUser)
            } catch {
                completion(configuredUser)
                print("JSON parsing error: " + error.localizedDescription)
            }
            
        }
    }

}
