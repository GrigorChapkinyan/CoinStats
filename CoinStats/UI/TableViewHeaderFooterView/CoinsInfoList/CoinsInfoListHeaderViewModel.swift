//
//  CoinsInfoListHeaderViewModel.swift
//  CoinStats
//
//  Created by Grigor Chapkinyan on 11.08.22.
//

import RxSwift
import RxCocoa

class CoinsInfoListHeaderViewModel {
    // MARK: - Input
    
    let priceSortingBtnTap = PublishRelay<Void>()
    
    // MARK: - Output
    
    let priceSortingIsUp = BehaviorRelay<Bool>(value: true)
    
    // MARK: - Private Properties
    
    private let bag = DisposeBag()
    
    // MARK: - Initializers
    
    init() {
        setupInitialBindings()
    }
    
    // MARK: - Helpers
    
    private func setupInitialBindings() {
        priceSortingBtnTap
            .observe(on: SerialDispatchQueueScheduler(qos: .default))
            .map({ [weak self] in
                return (self?.priceSortingIsUp.value == true) ? false : true
            })
            .bind(to: priceSortingIsUp)
            .disposed(by: bag)
    }
}
