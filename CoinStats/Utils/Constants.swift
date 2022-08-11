//
//  Constants.swift
//  CoinStats
//
//  Created by Grigor Chapkinyan on 09.08.22.
//

import Foundation
import CoreGraphics

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
    
    enum HttpBodyKeys: String {
        case coins = "coins"
    }
    
    enum CryptoPricePresentationType {
        case usd
        case btc
    }
    
    enum ColorNames: String {
        case lightRed = "lightRed"
        case darkRed = "darkRed"
        case lightGreen = "lightGreen"
        case darkGreen = "darkGreen"
        case gray1 = "gray1"
        case gray2 = "gray2"
        case gray3 = "gray3"
        case gray4 = "gray4"
        case gray5 = "gray5"
    }
    
    static let requestJsonHeaders = ["Content-Type": "application/json","Accept": "application/json"]
}
