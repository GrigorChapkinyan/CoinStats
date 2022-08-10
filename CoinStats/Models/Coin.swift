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
    let rank: Double
    let priceInUsd: Double
    let priceInBtc: Double
    let volumeUsedInLast24Hours: Double
    let name: String
    let symbol: String
    let iconUrl: String
    let marketCapInUsd: Double
    let percentChangeFor1H: Double
    let percentChangeFor24H: Double
    let percentChangeFor7Days: Double
    
    // MARK: - Initializers
    
    init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(String.self, forKey: .id)
        rank = try values.decode(Double.self, forKey: .rank)
        priceInUsd = try values.decode(Double.self, forKey: .priceInUsd)
        priceInBtc = try values.decode(Double.self, forKey: .priceInBtc)
        volumeUsedInLast24Hours = try values.decode(Double.self, forKey: .volumeUsedInLast24Hours)
        name = try values.decode(String.self, forKey: .name)
        symbol = try values.decode(String.self, forKey: .symbol)
        iconUrl = try values.decode(String.self, forKey: .iconUrl)
        marketCapInUsd = try values.decode(Double.self, forKey: .marketCapInUsd)
        percentChangeFor1H = try values.decode(Double.self, forKey: .percentChangeFor1H)
        percentChangeFor24H = try values.decode(Double.self, forKey: .percentChangeFor24H)
        percentChangeFor7Days = try values.decode(Double.self, forKey: .percentChangeFor7Days)
    }
    
    init?(from updatedDataArray:[Any],and previousObjects: [Coin]) {
        guard   updatedDataArray.count > 8,
                let id = updatedDataArray[0] as? String,
                let rank = updatedDataArray[1] as? Double,
                let priceInUsd = updatedDataArray[2] as? Double,
                let priceInBtc = updatedDataArray[3] as? Double,
                let volumeUsedInLast24Hours = updatedDataArray[4] as? Double,
                let marketCapInUsd = updatedDataArray[5] as? Double,
                let percentChangeFor1H = updatedDataArray[6] as? Double,
                let percentChangeFor24H = updatedDataArray[7] as? Double,
                let percentChangeFor7Days = updatedDataArray[7] as? Double else {
            return nil
        }

        // Trying to get the same previous coin
        var previousSameCoin: Coin?
        for previousCoin in previousObjects {
            if (id == previousCoin.id) {
                previousSameCoin = previousCoin
            }
        }
        
        // Checking the previous same coin to not be nil
        if previousSameCoin == nil {
            return nil
        }
        
        self.name = previousSameCoin!.name
        self.iconUrl = previousSameCoin!.iconUrl
        self.symbol = previousSameCoin!.symbol
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
