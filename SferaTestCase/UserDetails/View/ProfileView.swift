//
//  ProfileView.swift
//  SferaTestCase
//
//  Created by Anya on 09.09.2020.
//  Copyright © 2020 Anna Vondrukhova. All rights reserved.
//

import UIKit

class ProfileView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var accountLabel: UILabel!
    @IBOutlet var joinedLabel: UILabel!
    @IBOutlet var locationImage: UIImageView!
    @IBOutlet var locationLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
    }
    
    private func customInit() {
        Bundle.main.loadNibNamed("ProfileView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        avatarImage.layer.cornerRadius = avatarImage.frame.height/2
    }
    
    func configure(with user: User) {
        accountLabel.text = user.login
        AvatarService.shared.downloadImage(urlString: user.avatarUrl) { (image) in
            self.avatarImage.image = image
        }
        let name = user.name ?? ""
        nameLabel.text = name
        
        if let joined = user.createdAt {
            joinedLabel.text = "Joined " + joined
        } else {
            joinedLabel.text = ""
        }
        
        if let location = user.location {
            locationImage.isHidden = false
            locationLabel.text = location
        } else {
            locationImage.isHidden = true
            locationLabel.text = ""
        }
        
    }
}
