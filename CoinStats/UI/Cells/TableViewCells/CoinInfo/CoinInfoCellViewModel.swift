//
//  CoinInfoCellViewModel.swift
//  CoinStats
//
//  Created by Grigor Chapkinyan on 10.08.22.
//

import RxSwift
import RxCocoa

class CoinInfoCellViewModel {
    // MARK: - Input
    
    // MARK: - Output
    
    let priceInUsd = BehaviorRelay<Double?>(value: nil)
    let rank = BehaviorRelay<Double?>(value:nil)
    let name = BehaviorRelay<String?>(value: nil)
    let symbol = BehaviorRelay<String?>(value: nil)
    let iconUrl = BehaviorRelay<String?>(value: nil)
    let percentChangeFor24H = BehaviorRelay<Double?>(value: nil)
    
    init(with coin:Coin) {
        priceInUsd.accept(coin.priceInUsd)
        rank.accept(coin.rank)
        name.accept(coin.name)
        symbol.accept(coin.symbol)
        iconUrl.accept(coin.iconUrl)
        percentChangeFor24H.accept(coin.percentChangeFor24H)
    }
}
