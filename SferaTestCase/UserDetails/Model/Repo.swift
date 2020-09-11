//
//  Repo.swift
//  SferaTestCase
//
//  Created by Anya on 10.09.2020.
//  Copyright © 2020 Anna Vondrukhova. All rights reserved.
//

import Foundation

struct Repo {
    let id: Int
    let name: String
    let language: String
    let stars: Int
    var updatedAt: String
    
    private var dateFormatterTo: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yyyy HH:mm"
        return df
    }
    private var dateFormatterFrom: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return df
    }
    
    init?(dict: [String:Any]) {
        guard let id = dict["id"] as? Int,
            let name = dict["name"] as? String,
            let language = dict["language"] as? String,
            let stars = dict["stargazers_count"] as? Int,
            let updatedAt = dict["updated_at"] as? String else { return nil }
        
        self.id = id
        self.name = name
        self.language = language
        self.stars = stars
        self.updatedAt = updatedAt
        
        configureUpdate()
    }
    
    mutating func configureUpdate() {
        guard let date = dateFormatterFrom.date(from: updatedAt) else { return }
        self.updatedAt = dateFormatterTo.string(from: date)
    }
}
