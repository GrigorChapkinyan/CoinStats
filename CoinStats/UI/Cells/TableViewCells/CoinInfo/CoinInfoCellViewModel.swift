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
    
    let priceType = BehaviorRelay<Constants.CryptoPricePresentationType>(value: .usd)
    
    // MARK: - Output
    
    let priceStr = BehaviorRelay<String?>(value: nil)
    let rank = BehaviorRelay<Double?>(value:nil)
    let name = BehaviorRelay<String?>(value: nil)
    let symbol = BehaviorRelay<String?>(value: nil)
    let iconUrl = BehaviorRelay<String?>(value: nil)
    let percentChangeFor24H = BehaviorRelay<Double?>(value: nil)
    let middleViewBGColorName = BehaviorRelay<Constants.ColorNames?>(value: nil)
    let middleViewSubviewsBGColorName = BehaviorRelay<Constants.ColorNames?>(value: nil)

    // MARK: - Private Properties
    
    private let coin: Coin
    private let bag = DisposeBag()
    
    // MARK: - Initializers
    
    init(with coin:Coin) {
        self.coin = coin
        emmitValues()
        setupInitialBindings()
    }
    
    // MARK: - Private API
    
    private func emmitValues() {
        rank.accept(coin.rank)
        name.accept(coin.name)
        symbol.accept(coin.symbol)
        iconUrl.accept(coin.iconUrl)
        emmitCorrectPriceValue()
        
        let correctPercentChangeFor24H = Utils.changeDoublePrecision(initialDouble: coin.percentChangeFor24H, precision: 2)
        percentChangeFor24H.accept(abs(correctPercentChangeFor24H))
        
        let middleViewBGColorName: Constants.ColorNames = (correctPercentChangeFor24H < 0) ? .lightRed : .lightGreen
        self.middleViewBGColorName.accept(middleViewBGColorName)
        
        let middleViewSubviewsBGColorName: Constants.ColorNames = (correctPercentChangeFor24H < 0) ? .darkRed : .darkGreen
        self.middleViewSubviewsBGColorName.accept(middleViewSubviewsBGColorName)
    }
    
    private func emmitCorrectPriceValue() {
        var priceDigit: Double
        var priceSymbol: String
        
        switch (priceType.value) {
            case .usd:
                priceDigit = coin.priceInUsd
                priceSymbol = "$"
            
            case .btc:
                priceDigit = coin.priceInBtc
                priceSymbol = "Ƀ"
        }
        
        let priceStr = String((priceSymbol + String(format: "%.8f",priceDigit)).prefix(10))
        self.priceStr.accept(priceStr)
    }
    
    private func setupInitialBindings() {
        priceType
            .observe(on: SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext:{ [weak self] (_) in
                self?.emmitCorrectPriceValue()
            })
            .disposed(by: bag)
    }
}
