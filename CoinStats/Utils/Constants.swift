//
//  Constants.swift
//  CoinStats
//
//  Created by Grigor Chapkinyan on 09.08.22.
//

import Foundation

struct Constants {
    enum APIEndpoint: String {
        // Development API base URL
        #if DEBUG
            case baseUrl = "https://api.coin-stats.com/v3"
        // Release API base URL
        #else
            case baseUrl = "https://api.coin-stats.com/v3"
        #endif
        
        case coins = "/coins"
    }
}
