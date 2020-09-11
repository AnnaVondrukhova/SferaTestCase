//
//  AvatarService.swift
//  SferaTestCase
//
//  Created by Anya on 08.09.2020.
//  Copyright © 2020 Anna Vondrukhova. All rights reserved.
//

import Foundation
import UIKit

class AvatarService {
    static let shared = AvatarService()
    
    func downloadImage(urlString: String, completion:  @escaping (UIImage) -> ()) {
        guard let url = URL(string: urlString) else { return }
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(UIImage())
                }
            }
        }
        dataTask.resume()
    }
    
    
}
