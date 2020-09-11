//
//  UserDetailsViewController.swift
//  SferaTestCase
//
//  Created by Anya on 09.09.2020.
//  Copyright © 2020 Anna Vondrukhova. All rights reserved.
//

import UIKit

class UserDetailsViewController: UIViewController {
    @IBOutlet var profileView: ProfileView!
    @IBOutlet var tableView: UITableView!
    
    var user = User()
    var selectedIDs = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        UserDetailsService.shared.delegate = self
        
        let userCellNib = UINib.init(nibName: "RepoCell", bundle: nil)
        tableView.register(userCellNib, forCellReuseIdentifier: "repoCell")
        
        self.profileView.configure(with: user)
        
        UserDetailsService.shared.getUserDetails(user: user) { (configuredUser) in
            self.user = configuredUser
            
            DispatchQueue.main.async {
                self.profileView.configure(with: configuredUser)
            }
            
            RepoService.shared.fetchRepos(for: self.user) { (fetchedRepos) in
                self.user.repos = fetchedRepos
                self.tableView.reloadData()
            }
        }
    }
}

extension UserDetailsViewController: UITableViewDelegate, UITableViewDataSource, RepoCellDelegate {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let repos = user.repos, repos.isEmpty == false else {
            tableView.backgroundView = setUpBackgroundLabel()
            tableView.separatorStyle = .none
            return 0
        }
        
        tableView.backgroundView = nil
        tableView.separatorStyle = .singleLine
        return repos.count 
    }
    
    func setUpBackgroundLabel() -> UILabel {
        let backgroundLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        backgroundLabel.text = "No Data"
        backgroundLabel.font = .systemFont(ofSize: 27, weight: .semibold)
        backgroundLabel.textColor = .lightGray
        backgroundLabel.textAlignment = .center
        return backgroundLabel
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "repoCell") as? RepoCell,
            let repos = user.repos else { return RepoCell() }
        
        let repo = repos[indexPath.row]
        if selectedIDs.contains(repo.id) {
            cell.configureUnfolded(with: repo)
        } else {
            cell.configureFolded(with: repo)
        }
        
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let repos = user.repos else { return 60 }
        let repo = repos[indexPath.row]
        
        if selectedIDs.contains(repo.id) {
            return 90
        } else {
            return 60
        }
    }
    
    func foldButtonTapped(in cell: RepoCell) {
        guard let row = tableView.indexPath(for: cell)?.row,
            let repos = user.repos else { return }
        
        let id = repos[row].id
        if selectedIDs.contains(id) {
            let index = selectedIDs.firstIndex(of: id)!
            selectedIDs.remove(at: index)
            cell.configureFolded(with: repos[row])
        } else {
            selectedIDs.append(id)
            cell.configureUnfolded(with: repos[row])
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }

}

extension UserDetailsViewController: UserDetailsServiceDelegate {
    func showAlert(message: String) {
        AlertService.showNetworkAlert(in: self, message: message)
    }
}
