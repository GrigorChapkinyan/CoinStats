//
//  CoinsInfoListViewModel.swift
//  CoinStats
//
//  Created by Grigor Chapkinyan on 10.08.22.
//

import RxSwift
import RxCocoa

class CoinsInfoListViewModel {
    // MARK: - Input
    
    let updateDataObservable = PublishRelay<Void>()
    let searchPhrase = BehaviorRelay<String?>(value: nil)
    let priceType = BehaviorRelay<Constants.CryptoPricePresentationType>(value: .usd)

    // MARK: - Output
    
    let isLoading = BehaviorRelay<Bool>(value: false)
    let coinInfoCellsViewModels = BehaviorRelay<[CoinInfoCellViewModel]?>(value: nil)
    let error = BehaviorRelay<Error?>(value: nil)
    
    // MARK: - Private Properties
    
    private let bag = DisposeBag()
    private var cellViewModelsReuseableBug = DisposeBag()
    private var updateDataTimer: Timer?
    private let coinsData = BehaviorRelay<[Coin]?>(value: nil)
    
    // MARK: - Initializers
    
    init() {
        setupInitialBindings()
    }
    
    // MARK: - Private API
    
    private func setupInitialBindings() {
        updateDataObservable
            .observe(on: SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [weak self] _ in
                self?.updateDataHandler()
            })
            .disposed(by: bag)
        
        Observable
            .combineLatest(coinsData.compactMap({$0}), searchPhrase.observe(on: SerialDispatchQueueScheduler(qos: .default)))
            .map({ [weak self] (coins, searchPhrase) in
                guard let strongSelf = self else {
                    return nil
                }
                
                let filteredCoins = strongSelf.getFilteredCoins(allCoins: coins, searchPhrase: searchPhrase)
                return filteredCoins.map({ CoinInfoCellViewModel(with: $0) })
            })
            .compactMap({ $0 })
            .bind(to: coinInfoCellsViewModels)
            .disposed(by: bag)
        
        coinsData
            .compactMap({ $0 })
            .map({ $0.map({ CoinInfoCellViewModel(with: $0) }) })
            .bind(to: coinInfoCellsViewModels)
            .disposed(by: bag)
        
        coinInfoCellsViewModels
            .subscribe(onNext: { [weak self] (viewModels) in
                self?.resetCellViewModelsBindings()
            })
            .disposed(by: bag)
    }
    
    @objc private func updateDataHandler() {
        isLoading.accept(true)
        
        if let initialCoins = coinsData.value {
            CoinDataManager
                .shared
                .fetchAndUpdateAllCoinsData(with: initialCoins)
                .subscribe(
                    onNext: { [weak self] (coins) in
                        self?.coinsData.accept(coins)
                        self?.isLoading.accept(false)
                    },
                    onError: { [weak self] (error) in
                        self?.error.accept(error)
                        self?.isLoading.accept(false)
                    }
                )
                .disposed(by: bag)
        }
        else {
            CoinDataManager
                .shared
                .fetchAllCoinsInitialData()
                .subscribe(
                    onNext: { [weak self] (coins) in
                        self?.coinsData.accept(coins)
                        self?.isLoading.accept(false)
                        
                        // This code will be executed only once during this class instance liftime,
                        // and this is the place to setup the data updater timer
                        self?.setupUpdateDataTimer()
                    },
                    onError: { [weak self] (error) in
                        self?.error.accept(error)
                        self?.isLoading.accept(false)
                    }
                )
                .disposed(by: bag)
        }
    }
    
    private func setupUpdateDataTimer() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] timer in
            self?.updateDataHandler()
        }
    }
    
    private func getFilteredCoins(allCoins: [Coin], searchPhrase: String?) -> [Coin] {
        guard let searchPhrase = searchPhrase,
              !searchPhrase.isEmpty else {
            return allCoins
        }
        
        return allCoins.filter({ $0.name.contains(searchPhrase) })
    }
    
    private func resetCellViewModelsBindings() {
        cellViewModelsReuseableBug = DisposeBag()
        
        guard let coinInfoCellsViewModels = coinInfoCellsViewModels.value else {
            return
        }
        
        for cellViewModelter in coinInfoCellsViewModels {
            priceType
                .bind(to: cellViewModelter.priceType)
                .disposed(by: cellViewModelsReuseableBug)
        }
    }
}
