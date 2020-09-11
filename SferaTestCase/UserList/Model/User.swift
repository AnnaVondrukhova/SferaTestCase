//
//  User.swift
//  SferaTestCase
//
//  Created by Anya on 08.09.2020.
//  Copyright © 2020 Anna Vondrukhova. All rights reserved.
//

import Foundation
import UIKit

struct User {
    var login: String
    var type:String
    var avatarUrl: String
    var name: String?
    var createdAt: String?
    var location: String?
    var repos: [Repo]?
    
    private var dateFormatterTo: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yyyy"
        return df
    }
    private var dateFormatterFrom: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return df
    }
    
    init() {
        self.login = ""
        self.type = ""
        self.avatarUrl = ""
    }
    
    init?(dict: [String:Any]) {
        guard let login = dict["login"] as? String,
            let type = dict["type"] as? String,
            let avatarUrl = dict["avatar_url"] as? String else { return nil }
        
        self.login = login
        self.type = type
        self.avatarUrl = avatarUrl
    }
    
    mutating func configure(with dict: [String:Any]) {
        let name = dict["name"] as? String
        let location = dict["location"] as? String
        
        self.name = name
        self.location = location
        
        guard let createdAt = dict["created_at"] as? String else { return }
        guard let date = dateFormatterFrom.date(from: createdAt) else { return }
        self.createdAt = dateFormatterTo.string(from: date)
    }
}
