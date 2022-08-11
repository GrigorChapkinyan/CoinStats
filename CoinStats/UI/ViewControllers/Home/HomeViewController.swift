//
//  HomeViewController.swift
//  CoinStats
//
//  Created by Grigor Chapkinyan on 10.08.22.
//

import UIKit
import RxSwift

class HomeViewController: UIViewController {
    // MARK: - Outlets
    
    @IBOutlet private weak var priceTypeBtn: UIButton!
    @IBOutlet private weak var searchBtn: UIButton!
    @IBOutlet private weak var coinsInfoListView: CoinsInfoListView!
    
    // MARK: - Private Properties
    
    private let bag = DisposeBag()
    private let viewModel = HomeViewModel()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewModelBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.updateData.accept(())
    }
    
    // MARK: - Private API
    
    private func setupViewModelBindings() {
        viewModel
            .priceTypeBtnTitle
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: priceTypeBtn.rx.title())
            .disposed(by: bag)
        
        viewModel
            .coinsInfoListViewModel
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (coinsInfoListViewModel) in
                self?.coinsInfoListView.setupViewModel(coinsInfoListViewModel)
            })
            .disposed(by: bag)
        
        viewModel
            .isLoading
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { (_) in

            })
            .disposed(by: bag)
        
        viewModel
            .error
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { (_) in

            })
            .disposed(by: bag)
        
        priceTypeBtn
            .rx
            .tap
            .bind(to: viewModel.priceTypeBtnTap)
            .disposed(by: bag)
    }
}
