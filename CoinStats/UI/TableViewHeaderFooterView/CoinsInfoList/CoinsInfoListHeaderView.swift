//
//  CoinsInfoListHeaderView.swift
//  CoinStats
//
//  Created by Grigor Chapkinyan on 10.08.22.
//

import UIKit
import RxSwift
import RxCocoa

class CoinsInfoListHeaderView: UIView {
    // MARK: - Outlets
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var priceSortingBtn: UIButton!
    @IBOutlet private weak var priceSortingImageView: UIImageView!

    // MARK: Public Properties
    
    private static let nibFileName = "CoinsInfoListHeaderView"
    
    // MARK: - Private Properties
    
    private var reusableBag = DisposeBag()
    private var viewModel: CoinsInfoListHeaderViewModel?
    
    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - Public API
    
    func setupViewModel(_ viewModel: CoinsInfoListHeaderViewModel?) {
        self.viewModel = viewModel
        resetViewModelBindings()
    }
    
    // MARK: - Private API
    
    private func commonInit() {
        Bundle.main.loadNibNamed(CoinsInfoListHeaderView.nibFileName, owner: self, options: nil)
        contentView.fixInView(self)
    }
    
    private func resetViewModelBindings() {
        self.reusableBag = DisposeBag()
        
        guard let viewModel = viewModel else {
            return
        }

        priceSortingBtn
            .rx
            .tap
            .bind(to: viewModel.priceSortingBtnTap)
            .disposed(by: reusableBag)
        
        viewModel
            .priceSortingIsUp
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (isUp) in
                let imageName = isUp ? Constants.ImageAssetNames.sortIconUp.rawValue : Constants.ImageAssetNames.sortIconDown.rawValue
                self?.priceSortingImageView.image = UIImage(named: imageName)
            })
            .disposed(by: reusableBag)
    }
}
