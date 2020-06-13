//
//  APIService.swift
//  Converter X
//
//  Created by Georg on 13.06.2020.
//  Copyright © 2020 Georg. All rights reserved.
//

import Foundation

class APIService {
    static let instance = APIService()
    
    func getCurrencyRates(base: String = "USD", completion: @escaping (ExchangeRates) -> Void) {
        let baseURL = "https://api.exchangeratesapi.io/latest?base=\(base)"
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "GET"

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard let data = data else { return }
            let decoder = JSONDecoder()
            if let json = try? decoder.decode(ExchangeRates.self, from: data) {
                completion(json)
            }
        })
        task.resume()
    }
    
}
