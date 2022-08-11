//
//  CoinsInfoListView.swift
//  CoinStats
//
//  Created by Grigor Chapkinyan on 10.08.22.
//

import UIKit
import RxCocoa
import RxSwift

class CoinsInfoListView: UIView, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Outlets
    
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private Properties
    
    private var viewModel: CoinsInfoListViewModel?
    private var reusableBag = DisposeBag()
    private static let nibFileName = "CoinsInfoListView"
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureUIInitialState()
    }
    
    // MARK: - Public API
    
    func setupViewModel(_ viewModel:CoinsInfoListViewModel?) {
        self.viewModel = viewModel
        resetViewModelBindings()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.coinInfoCellsViewModels.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellViewModels = viewModel?.coinInfoCellsViewModels.value,
              let cell = tableView.dequeueReusableCell(withIdentifier: CoinInfoTableViewCell.reuseIdentifier, for: indexPath) as? CoinInfoTableViewCell  else {
            return UITableViewCell()
        }
        
        cell.setupViewModel(cellViewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return (viewModel?.coinInfoCellsViewModels.value == nil) ? nil : tableView.dequeueReusableHeaderFooterView(withIdentifier: CoinsInfoListHeaderFooterView.reusieIdentifier)
    }
    
    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.bounds.width * (51 / 343)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.bounds.width * (1 / 8)
    }
    
    // MARK: - Private API
    
    private func commonInit() {
        Bundle.main.loadNibNamed(CoinsInfoListView.nibFileName, owner: self, options: nil)
        contentView.fixInView(self)
    }
    
    private func resetViewModelBindings() {
        reusableBag = DisposeBag()
        
        guard let viewModel = viewModel else {
            return
        }

        viewModel
            .coinInfoCellsViewModels
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [weak self] (rank) in
                self?.tableView.reloadData()
            }
            .disposed(by: reusableBag)
    }
    
    private func configureUIInitialState() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: CoinInfoTableViewCell.nibFileName, bundle: nil), forCellReuseIdentifier: CoinInfoTableViewCell.reuseIdentifier)
        tableView.register(UINib(nibName: CoinsInfoListHeaderFooterView.nibFileName, bundle: nil), forHeaderFooterViewReuseIdentifier: CoinsInfoListHeaderFooterView.reusieIdentifier)
    }
}
