//
//  UserCell.swift
//  SferaTestCase
//
//  Created by Anya on 08.09.2020.
//  Copyright © 2020 Anna Vondrukhova. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var accountLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImage.layer.cornerRadius = avatarImage.layer.frame.height/2
    }

    func configure(with user: User) {
        self.selectionStyle = .none
        accountLabel.text = user.login
        typeLabel.text = user.type
        AvatarService.shared.downloadImage(urlString: user.avatarUrl) { (image) in
            self.avatarImage.image = image
        }
    }
    

}
