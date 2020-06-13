//
//  Currency.swift
//  Converter X
//
//  Created by Georg on 13.06.2020.
//  Copyright © 2020 Georg. All rights reserved.
//

import Foundation

class ExchangeRates: Decodable {
    let rates: [String:Double]
    let base: String!
    let date: String!
    
    enum CodingKeys: String, CodingKey {
        case rates = "rates"
        case base = "base"
        case date = "date"
    }
}
