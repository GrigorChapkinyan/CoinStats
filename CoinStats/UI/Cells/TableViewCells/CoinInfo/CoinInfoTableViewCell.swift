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
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var rankLabel: UILabel!
    @IBOutlet private weak var rankLabelContainerView: UIView!

    // MARK: - Public Properties
    
    static let reuseIdentifier = "CoinInfoTableViewCell"
    static let nibFileName = "CoinInfoTableViewCell"

    // MARK: - Private Properties
    
    private var reusableBag = DisposeBag()
    private var viewModel: CoinInfoCellViewModel?
    private var middleViewXCenterConstraintWasCorrected = false
    
    // MARK: - View Life Cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureCornerRadiuses()
    }
    
    // MARK: - Public API
    
    func setupViewModel(_ viewModel: CoinInfoCellViewModel?) {
        self.viewModel = viewModel
        resetViewModelBindings()
    }
    
    // MARK: - Private API
    
    private func resetViewModelBindings() {
        reusableBag = DisposeBag()

        guard let viewModel = viewModel else {
            return
        }

        viewModel
            .priceStr
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: priceLabel.rx.text)
            .disposed(by: reusableBag)
        
        viewModel
            .name
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: nameLabel.rx.text)
            .disposed(by: reusableBag)
        
        viewModel
            .rank
            .compactMap({ $0 })
            .map({ String(Int($0)) })
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: rankLabel.rx.text)
            .disposed(by: reusableBag)
        
        viewModel
            .iconUrl
            .compactMap({ $0 })
            .map({ URL(string: $0) })
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [weak self] (iconUrl) in
                self?.iconImageView.sd_setImage(with: iconUrl)
            }
            .disposed(by: reusableBag)
        
        viewModel
            .symbol
            .compactMap({ $0 })
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: symbolLabel.rx.text)
            .disposed(by: reusableBag)
        
        viewModel
            .percentChangeFor24H
            .compactMap({ $0 })
            .map({ String($0) })
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: priceChange24HLabel.rx.text)
            .disposed(by: reusableBag)
        
        viewModel
            .middleViewBGColorName
            .compactMap({ $0 })
            .observe(on: MainScheduler.asyncInstance)
            .map({ UIColor(named: $0.rawValue) })
            .bind(to: middleView.rx.backgroundColor)
            .disposed(by: reusableBag)
        
        viewModel
            .middleViewSubviewsBGColorName
            .compactMap({ $0 })
            .observe(on: MainScheduler.asyncInstance)
            .map({ UIColor(named: $0.rawValue) })
            .bind(to: priceChange24HLabel.rx.textColor)
            .disposed(by: reusableBag)
        
        Observable
            .combineLatest(
                viewModel.middleViewSubviewsBGColorName.compactMap({ $0 }),
                viewModel.arrowImageName.compactMap({ $0 })
            )
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [weak self] (colorName, imageName) in
                guard let color = UIColor(named: colorName.rawValue) else {
                    return
                }
                
                self?.priceChange24HIconImageView.image = UIImage(named: imageName.rawValue)?.sd_tintedImage(with: color)
            }
            .disposed(by: reusableBag)
    }
    
    private func configureCornerRadiuses() {
        middleView.layer.cornerRadius = 8
        rankLabelContainerView.layer.cornerRadius = 4
    }
}
