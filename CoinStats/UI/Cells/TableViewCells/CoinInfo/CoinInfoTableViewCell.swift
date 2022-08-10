//
//  CoinInfoTableViewCell.swift
//  CoinStats
//
//  Created by Grigor Chapkinyan on 10.08.22.
//

import UIKit
import RxSwift
import SDWebImage

class CoinInfoTableViewCell: UITableViewCell {
    // MARK: - IBOutlets
    
    @IBOutlet private weak var middleView: UIView!
    @IBOutlet private weak var middleViewXCenterConstraint: NSLayoutConstraint!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var symbolLabel: UILabel!
    @IBOutlet private weak var priceChange24HLabel: UILabel!
    @IBOutlet private weak var priceChange24HIconImageView: UIImageView!
    @IBOutlet private weak var priceInUsdLabel: UILabel!
    @IBOutlet private weak var rankLabel: UILabel!
    
    // MARK: - Public Properties
    
    static let reuseIdentifier = "CoinInfoTableViewCell"

    // MARK: - Private Properties
    
    private var reusableBag = DisposeBag()
    private var viewModel: CoinInfoCellViewModel?
    
    // MARK: - View Life Cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureMiddleViewXCenterConstraint()
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }

//    override func prepareForReuse() {
//        super.prepareForReuse()
//
//        resetViewModelBindings()
//    }
    
    // MARK: - Public API
    
    func setupViewModel(_ viewModel: CoinInfoCellViewModel?) {
        self.viewModel = viewModel
        resetViewModelBindings()
    }
    
    // MARK: - Private API
    
    private func configureMiddleViewXCenterConstraint() {
        let newXCenterMultiplier = Utils.getXAxisCenterConstraintCalculatedMultiplier(parentView: contentView, childView: middleView, leadingConstraintMultiplier: Constants.middleRowLeadingPositionPortion)
        
        // If the calculated and existing multipliers are the same,
        // we must return, for avoiding recursion
        guard newXCenterMultiplier != middleViewXCenterConstraint.multiplier else {
            return
        }
        
        let newConstraintTemp = middleViewXCenterConstraint.constraintWithMultiplier(newXCenterMultiplier)
        middleViewXCenterConstraint.isActive = false
        newConstraintTemp.isActive = true
        middleViewXCenterConstraint = newConstraintTemp
    }
    
    private func resetViewModelBindings() {
        reusableBag = DisposeBag()

        guard let viewModel = viewModel else {
            return
        }

        viewModel
            .priceInUsd
            .compactMap({ $0 })
            .map({ String($0) })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (price) in
                self?.priceInUsdLabel.text = price
            })
            .disposed(by: reusableBag)
        
        viewModel
            .name
            .compactMap({ $0 })
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] (name) in
                self?.nameLabel.text = name
            }
            .disposed(by: reusableBag)
        
        viewModel
            .rank
            .compactMap({ $0 })
            .map({ String(Int($0)) })
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] (rank) in
                self?.rankLabel.text = rank
            }
            .disposed(by: reusableBag)
        
        viewModel
            .iconUrl
            .compactMap({ $0 })
            .map({ URL(string: $0) })
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] (iconUrl) in
                self?.iconImageView.sd_setImage(with: iconUrl)
            }
            .disposed(by: reusableBag)
        
        viewModel
            .symbol
            .compactMap({ $0 })
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] (symbol) in
                self?.symbolLabel.text = symbol
            }
            .disposed(by: reusableBag)
        
        viewModel
            .percentChangeFor24H
            .compactMap({ $0 })
            .map({ String($0) })
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] (text) in
                self?.priceChange24HLabel.text = text
            }
            .disposed(by: reusableBag)
    }
}
