//
//  UserListViewController.swift
//  SferaTestCase
//
//  Created by Anya on 07.09.2020.
//  Copyright © 2020 Anna Vondrukhova. All rights reserved.
//

import UIKit

enum SortType: String {
    case bestMatch = "best match"
    case accountAZ = "account (A-Z)"
    case accountZA = "account (Z-A)"
}

class UserListViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var sortButton: UIButton!
    @IBOutlet var loadingView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    private var fetchedUsers = [User]()
    private var sortedUsers = [User]()
    private var downloadedUsers = [User]()
    
    private var index = 0
    private var pageAmount = 20
    private var downloadNeeded = false
    private var sortType: SortType = .bestMatch {
        didSet {
            sortButton.setTitle(sortType.rawValue, for: .normal)
        }
    }
    
    private var isAuthorized = (UserDefaults.standard.object(forKey: "isAuthorized") as? Bool) ?? false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        navigationController?.isNavigationBarHidden = true
        UserService.shared.delegate = self
        
        let userCellNib = UINib.init(nibName: "UserCell", bundle: nil)
        tableView.register(userCellNib, forCellReuseIdentifier: "userCell")
        
        let activityIndicatorCellNib = UINib.init(nibName: "ActivityIndicatorCell", bundle: nil)
        tableView.register(activityIndicatorCellNib, forCellReuseIdentifier: "activityIndicatorCell")
        tableView.rowHeight = 60
                
        sortButton.setTitle(sortType.rawValue, for: .normal)
        
        activityIndicator.hidesWhenStopped = true
            
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if !isAuthorized {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let vc = storyboard.instantiateViewController(identifier: "loginViewController")
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            
            present(vc, animated: true, completion: nil)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
        
    //search bar functions
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        loadingView.isHidden = false
        activityIndicator.startAnimating()
        
        index = 0
        sortType = .bestMatch
        
        guard let name = searchBar.text?.lowercased() else { return }
        
        DispatchQueue.global().async {
            UserService.shared.fetchUsers(name: name) {(fetchedUsers) in
                self.fetchedUsers = fetchedUsers
                self.sortedUsers = self.setSortedUsers(users: self.fetchedUsers)
                self.setDownloadedUsers()
                
                self.loadingView.isHidden = true
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
                self.searchBar.text = nil
                print("****Users amount: ", self.sortedUsers.count)
            }
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        view.endEditing(true)
    }
    
    //hide and show keyboard and cancel button
    @objc func keyboardWasShown(_ notification: Notification) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    @objc func keyboardWillBeHidden(_ notification: Notification) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    
    //setting table view users
    func setSortedUsers(users: [User]) -> [User] {
        switch sortType {
        case .bestMatch:
            return users
        case .accountAZ:
            return users.sorted{$0.login.lowercased() <= $1.login.lowercased() }
        case .accountZA:
            return users.sorted{$0.login.lowercased() >= $1.login.lowercased() }
        }
    }
    
    func setDownloadedUsers() {
        if self.sortedUsers.count <= self.pageAmount {
            self.downloadNeeded = false
            self.downloadedUsers = self.sortedUsers
        } else {
            self.downloadNeeded = true
            self.downloadedUsers = Array(self.sortedUsers[self.index..<self.index+self.pageAmount])
            self.index += self.pageAmount
        }
    }
    
    func updateResults() {
        self.sortedUsers = self.setSortedUsers(users: self.fetchedUsers)
        self.index = 0
        self.setDownloadedUsers()
        self.tableView.reloadData()
    }
    
    
    
    //sorting users
    @IBAction func sortButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Sort options", message: nil, preferredStyle: .actionSheet)
        let bestMatchAction = UIAlertAction(title: SortType.bestMatch.rawValue, style: .default) { (_) in
            self.sortType = .bestMatch
            self.updateResults()
        }
        let azAction = UIAlertAction(title: SortType.accountAZ.rawValue, style: .default) { (_) in
            self.sortType = .accountAZ
            self.updateResults()
        }
        let zaAction = UIAlertAction(title: SortType.accountZA.rawValue, style: .default) { (_) in
            self.sortType = .accountZA
            self.updateResults()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(bestMatchAction)
        alertController.addAction(azAction)
        alertController.addAction(zaAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: tableview functions
extension UserListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if downloadedUsers.isEmpty {
                tableView.backgroundView = setUpBackgroundLabel()
                tableView.separatorStyle = .none
                return 0
            } else {
                return downloadedUsers.count
            }
        } else if section == 1 && downloadNeeded {
            return 1
        } else {
            return 0
        }
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
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as? UserCell else { return UserCell() }
            let user = downloadedUsers[indexPath.row]
            cell.configure(with: user)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "activityIndicatorCell") as? ActivityIndicatorCell else { return UserCell() }
            cell.activityIndicator.startAnimating()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = downloadedUsers[indexPath.row]
        performSegue(withIdentifier: "showDetails", sender: user)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height {
            if downloadNeeded {
                addUsers()
            }
        }
    }
    
    func addUsers() {
        downloadNeeded = false
        tableView.reloadSections(IndexSet(integer: 1), with: .none)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let totalUsersAmount = self.sortedUsers.count
            var newUsers = [User]()
            if (self.index+self.pageAmount) <= totalUsersAmount {
                newUsers = Array(self.sortedUsers[self.index..<self.index+self.pageAmount])
                self.index += self.pageAmount
                self.downloadNeeded = true
            } else {
                newUsers = Array(self.sortedUsers[self.index..<totalUsersAmount])
            }
            
            self.downloadedUsers.append(contentsOf: newUsers)
            print("Downloaded \(self.downloadedUsers.count) users")
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let user = sender as? User else { return }
        guard let vc = segue.destination as? UserDetailsViewController else { return }
        vc.user = user
    }
}

extension UserListViewController: UserServiceDelegate {
    func showAlert(message: String) {
        AlertService.showNetworkAlert(in: self, message: message)
    }
}
