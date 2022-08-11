//
//  HomeViewModel.swift
//  CoinStats
//
//  Created by Grigor Chapkinyan on 10.08.22.
//

import RxSwift
import RxCocoa

class HomeViewModel {
    // MARK: - Input
    
    let updateData = PublishRelay<Void>()
    let priceTypeBtnTap = PublishRelay<Void>()
    let searchPhrase = BehaviorRelay<String?>(value: nil)
    
    // MARK: - Output
    
    let coinsInfoListViewModel = BehaviorRelay<CoinsInfoListViewModel>(value: CoinsInfoListViewModel())
    let isLoading = BehaviorRelay<Bool>(value: false)
    let error = BehaviorRelay<Error?>(value: nil)
    let priceTypeBtnTitle = BehaviorRelay<String?>(value: nil)

    // MARK: - Private Properties
    
    private let bag = DisposeBag()
    private var coinsInfoListViewModelReusableBag = DisposeBag()
    private let priceType = BehaviorRelay<Constants.CryptoPricePresentationType>(value: .usd)

    // MARK: - Initializers
    
    init() {
        setupInitialBindings()
    }
    
    // MARK: - Private API
    
    private func setupInitialBindings() {
        coinsInfoListViewModel
            .observe(on: SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [weak self] (_) in
                self?.resetCoinsInfoListViewModelBindings()
            })
            .disposed(by: bag)
        
        priceType
            .subscribe(onNext: { [weak self] (priceType) in
                let priceTypeBtnTytle = (priceType == .usd) ? "USD" : "BTC"
                self?.priceTypeBtnTitle.accept(priceTypeBtnTytle)
            })
            .disposed(by: bag)
        
        priceTypeBtnTap
            .subscribe(onNext: { [weak self] (_) in
                let flippedVal: Constants.CryptoPricePresentationType = (self?.priceType.value == .usd) ? .btc : .usd
                self?.priceType.accept(flippedVal)
            })
            .disposed(by: bag)
    }
    
    private func resetCoinsInfoListViewModelBindings() {
        coinsInfoListViewModelReusableBag = DisposeBag()
        
        priceType
            .observe(on: SerialDispatchQueueScheduler(qos: .default))
            .bind(to: coinsInfoListViewModel.value.priceType)
            .disposed(by: coinsInfoListViewModelReusableBag)
        
        searchPhrase
            .observe(on: SerialDispatchQueueScheduler(qos: .default))
            .bind(to: coinsInfoListViewModel.value.searchPhrase)
            .disposed(by: coinsInfoListViewModelReusableBag)
        
        coinsInfoListViewModel
            .value
            .isLoading
            .bind(to: isLoading)
            .disposed(by: coinsInfoListViewModelReusableBag)
        
        coinsInfoListViewModel
            .value
            .error
            .bind(to: error)
            .disposed(by: coinsInfoListViewModelReusableBag)
        
        updateData
            .observe(on: SerialDispatchQueueScheduler(qos: .default))
            .bind(to: coinsInfoListViewModel.value.updateDataObservable)
            .disposed(by: coinsInfoListViewModelReusableBag)
    }
}
