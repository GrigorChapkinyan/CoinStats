//
//  Coin.swift
//  CoinStats
//
//  Created by Grigor Chapkinyan on 09.08.22.
//

import Foundation

struct Coin: Codable {
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
    let rank: Int
    let priceInUsd: Int
    let priceInBtc: Int
    let volumeUsedInLast24Hours: Int
    let name: String
    let symbol: String
    let iconUrl: String
    let marketCapInUsd: Int
    let percentChangeFor1H: Int
    let percentChangeFor24H: Int
    let percentChangeFor7Days: Int
    
    // MARK: - Initializers
    
    init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(String.self, forKey: .id)
        rank = try values.decode(Int.self, forKey: .rank)
        priceInUsd = try values.decode(Int.self, forKey: .priceInUsd)
        priceInBtc = try values.decode(Int.self, forKey: .priceInBtc)
        volumeUsedInLast24Hours = try values.decode(Int.self, forKey: .volumeUsedInLast24Hours)
        name = try values.decode(String.self, forKey: .name)
        symbol = try values.decode(String.self, forKey: .symbol)
        iconUrl = try values.decode(String.self, forKey: .iconUrl)
        marketCapInUsd = try values.decode(Int.self, forKey: .marketCapInUsd)
        percentChangeFor1H = try values.decode(Int.self, forKey: .percentChangeFor1H)
        percentChangeFor24H = try values.decode(Int.self, forKey: .percentChangeFor24H)
        percentChangeFor7Days = try values.decode(Int.self, forKey: .percentChangeFor7Days)
    }
    
    init?(from updatedDataArray:[Any],and previousObject: Coin) {
        guard   updatedDataArray.count > 8,
                let id = updatedDataArray[0] as? String,
                let rank = updatedDataArray[1] as? Int,
                let priceInUsd = updatedDataArray[2] as? Int,
                let priceInBtc = updatedDataArray[3] as? Int,
                let volumeUsedInLast24Hours = updatedDataArray[4] as? Int,
                let marketCapInUsd = updatedDataArray[5] as? Int,
                let percentChangeFor1H = updatedDataArray[6] as? Int,
                let percentChangeFor24H = updatedDataArray[7] as? Int,
                let percentChangeFor7Days = updatedDataArray[7] as? Int else {
            return nil
        }

        self.name = previousObject.name
        self.iconUrl = previousObject.iconUrl
        self.symbol = previousObject.symbol
        self.id = id
        self.rank = rank
        self.priceInUsd = priceInUsd
        self.priceInBtc = priceInBtc
        self.volumeUsedInLast24Hours = volumeUsedInLast24Hours
        self.marketCapInUsd = marketCapInUsd
        self.percentChangeFor1H = percentChangeFor1H
        self.percentChangeFor24H = percentChangeFor24H
        self.percentChangeFor7Days = percentChangeFor7Days
    }
}
