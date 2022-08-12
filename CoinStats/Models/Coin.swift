//
//  Coin.swift
//  CoinStats
//
//  Created by Grigor Chapkinyan on 09.08.22.
//

import Foundation

class Coin: Codable {
    // MARK: - Nested Types
    
    enum CodingKeys: String, CodingKey {
        case id = "i"
        case rank = "r"
        case priceInUsd = "pu"
        case priceInBtc = "pb"
        case volumeUsedInLast24Hours = "v"
        case name = "n"
        case symbol = "s"
        case iconUrl = "ic"
        case marketCapInUsd = "m"
        case percentChangeFor1H = "p1"
        case percentChangeFor24H = "p24"
        case percentChangeFor7Days = "p7"
    }
    
    // MARK: - Public Properties
    
    let id: String
    let rank: Double
    private(set) var priceInUsd: Double
    private(set) var priceInBtc: Double
    let volumeUsedInLast24Hours: Double?
    let name: String
    let symbol: String
    let iconUrl: String
    let marketCapInUsd: Double?
    let percentChangeFor1H: Double?
    let percentChangeFor24H: Double
    let percentChangeFor7Days: Double?
    
    // MARK: - Initializers
    
    required init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(String.self, forKey: .id)
        rank = try values.decode(Double.self, forKey: .rank)
        priceInUsd = try values.decode(Double.self, forKey: .priceInUsd)
        priceInBtc = try values.decode(Double.self, forKey: .priceInBtc)
        volumeUsedInLast24Hours = try? values.decode(Double.self, forKey: .volumeUsedInLast24Hours)
        name = try values.decode(String.self, forKey: .name)
        symbol = try values.decode(String.self, forKey: .symbol)
        iconUrl = try values.decode(String.self, forKey: .iconUrl)
        marketCapInUsd = try? values.decode(Double.self, forKey: .marketCapInUsd)
        percentChangeFor1H = try? values.decode(Double.self, forKey: .percentChangeFor1H)
        percentChangeFor24H = try values.decode(Double.self, forKey: .percentChangeFor24H)
        percentChangeFor7Days = try? values.decode(Double.self, forKey: .percentChangeFor7Days)
    }
    
    func updatePrice(from updatedDataArray:[[Any]]) {
        // Iterating trough each updated data,
        // to find the data that matches with this coin
        for updatedData in updatedDataArray {
            // Checking if everything is correct
            guard updatedData.count > 3,
                  let id = updatedData[0] as? String,
                  id == self.id,
                  let priceInUsd = updatedData[2] as? Double,
                  let priceInBtc = updatedData[3] as? Double else {
                // Going to next iteration otherwise
                continue
            }
                    
            // data iter, and this coin match together,
            // so updating the data
            self.priceInUsd = priceInUsd
            self.priceInBtc = priceInBtc
            return
        }
        
        // If the code is here,
        // it means that an updated data for this coin
        // wasn't present in passed array, so logging an error in debugger
        print("Updated data wasn't found for coin with id: \(self.id)")
    }
}
