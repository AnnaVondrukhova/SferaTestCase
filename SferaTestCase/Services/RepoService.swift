//
//  RepoService.swift
//  SferaTestCase
//
//  Created by Anya on 10.09.2020.
//  Copyright © 2020 Anna Vondrukhova. All rights reserved.
//

import Foundation

class RepoService {
    static let shared = RepoService()
    
    func getRepoJSON(url: URL, completion: @escaping ([[String: Any]]) -> ()) {
        
        NetworkService.shared.getData(with: url) { (data, statusCode) in
            guard let data = data else {
                completion([[String: Any]]())
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                                
                guard let repos = jsonObject as? [[String: Any]] else {
                    completion([[String: Any]]())
                    return print("Invalid JSON")
                }
                completion(repos)
            } catch {
                completion([[String: Any]]())
                print("JSON parsing error: " + error.localizedDescription)
            }
            
        }
    }
    
    func fetchRepos(for user: User, completion: @escaping([Repo]) -> ()) {
        var fetchedRepos = [Repo]()

        guard let url = URL(string: "https://api.github.com/users/\(user.login.lowercased())/repos") else {
            completion(fetchedRepos)
            return
        }
        
        getRepoJSON(url: url) { repos in
            for repoDict in repos {
                guard let repo = Repo(dict: repoDict) else { continue }
                fetchedRepos.append(repo)
            }
            
            DispatchQueue.main.async {
                completion(fetchedRepos)
            }
        }
    }
}
