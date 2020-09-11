//
//  NetworkService.swift
//  SferaTestCase
//
//  Created by Anya on 07.09.2020.
//  Copyright © 2020 Anna Vondrukhova. All rights reserved.
//

import Foundation
import SwiftyJSON

class NetworkService {
    static let shared = NetworkService()
    var nextPageExist: Bool = false
    
    //общая функция для всех запросов
    func getData(with url: URL, completion: @escaping (Data?, Int) -> ()) {
        print(url)
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 7.0
        
        var session: URLSession
        
        
        if let login = UserDefaults.standard.object(forKey: "login") as? String,
            let password = UserDefaults.standard.object(forKey: "password") as? String {
            let configuration = URLSessionConfiguration.default
            let userPasswordString = "\(login):\(password)"
            let userPasswordData = userPasswordString.data(using: String.Encoding.utf8)
            let base64EncodedCredential = userPasswordData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let authString = "Basic \(base64EncodedCredential)"
            configuration.httpAdditionalHeaders = ["Authorization" : authString]
            
            session = URLSession(configuration: configuration)
        } else {
            session = URLSession.shared
        }
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                    if let err = error as? URLError, [URLError.Code.notConnectedToInternet, URLError.Code.timedOut].contains(err.code) {
                        completion(nil, err.code.rawValue)
                    }
                    completion(nil, 500)
                    return
            }
            
            print("Status code: ", response.statusCode)
            if let value = response.allHeaderFields["Link"] as? String {
                self.nextPageExist = value.contains("rel=\"next\"")
            }
            completion(data, response.statusCode)
            
        }
        dataTask.resume()
    }
    
    
}
