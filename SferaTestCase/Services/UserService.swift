//
//  UserService.swift
//  SferaTestCase
//
//  Created by Anya on 08.09.2020.
//  Copyright © 2020 Anna Vondrukhova. All rights reserved.
//

import Foundation

protocol UserServiceDelegate {
    func showAlert(message: String)
}

class UserService {
    static let shared = UserService()
    var usersArray: [User]?
    var delegate: UserListViewController!
    
    func getUserJSON(url: URL, completion: @escaping ([[String: Any]]) -> ()) {
        
        NetworkService.shared.getData(with: url) { (data, statusCode) in
            guard let data = data, statusCode == 200 else {
                var message = ""
                
                switch statusCode {
                case URLError.Code.notConnectedToInternet.rawValue:
                    message = "No internet connection"
                case URLError.Code.timedOut.rawValue:
                    message = "No internet connection"
                case 403:
                    message = "Exceeded limit of search reguests per minute"
                default:
                    message = "Server is not responding"
                }
                DispatchQueue.main.async {
                    self.delegate.showAlert(message: message)
                }
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                
                guard let json = jsonObject as? [String: Any] else {
                    completion([[String: Any]]())
                    return print("Invalid JSON")
                }
                
                guard let users = json["items"] as? [[String: Any]] else {
                    completion([[String: Any]]())
                    return print("Invalid JSON items")
                }
                completion(users)
            } catch {
                completion([[String: Any]]())
                print("JSON parsing error: " + error.localizedDescription)
            }
            
        }
    }
    
    func fetchUsers(name: String, completion: @escaping([User]) -> ()) {
        var page = 1
        
        let networkGroup = DispatchGroup()
        var fetchedUsers = [User]()

        repeat {
            guard let url = URL(string: "https://api.github.com/search/users?q=\(name)+in:login&page=\(page)&per_page=100") else {
                completion(fetchedUsers)
                return
            }
            
            networkGroup.enter()
            getUserJSON(url: url) { users in
                for userDict in users {
                    guard let user = User(dict: userDict) else { continue }
                    fetchedUsers.append(user)
                }
                print ("page \(page) downloaded")
                networkGroup.leave()
            }
            networkGroup.wait()
            page += 1
        } while NetworkService.shared.nextPageExist
        
        DispatchQueue.main.async {
            completion(fetchedUsers)
        }
        
    }

}
