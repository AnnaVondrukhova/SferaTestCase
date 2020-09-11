//
//  RepoCell.swift
//  SferaTestCase
//
//  Created by Anya on 10.09.2020.
//  Copyright © 2020 Anna Vondrukhova. All rights reserved.
//

import UIKit

protocol RepoCellDelegate {
    func foldButtonTapped(in cell: RepoCell)
}

class RepoCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var languageLabel: UILabel!
    @IBOutlet var starImage: UIImageView!
    @IBOutlet var starLabel: UILabel!
    @IBOutlet var updatedLabel: UILabel!
    @IBOutlet var foldButtonImage: UIImageView!
    
    var delegate: UserDetailsViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureFolded(with repo: Repo) {
        nameLabel.text = repo.name
        languageLabel.text = repo.language
        foldButtonImage.image = UIImage(systemName: "arrow.left.circle")
        starImage.isHidden = true
        starLabel.isHidden = true
        updatedLabel.isHidden = true
    }
    
    func configureUnfolded(with repo: Repo) {
        nameLabel.text = repo.name
        languageLabel.text = repo.language
        foldButtonImage.image = UIImage(systemName: "arrow.down.circle")
        starLabel.text = "\(repo.stars)"
        if repo.stars == 0 {
            starImage.image = UIImage(systemName: "star")
            starImage.tintColor = .darkGray
        } else {
            starImage.image = UIImage(systemName: "star.fill")
            starImage.tintColor = .systemYellow
        }
        updatedLabel.text = "Updated \(repo.updatedAt)"
        
        
        starImage.isHidden = false
        starLabel.isHidden = false
        updatedLabel.isHidden = false
    }

    @IBAction func foldButtonTapped(_ sender: Any) {
        delegate.foldButtonTapped(in: self)
    }
}
