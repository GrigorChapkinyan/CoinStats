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
              // This row of logic is needed for avoiding crashes,
              // when search input and data update are mixing together very fast
              cellViewModels.count > indexPath.row,
              let cell = tableView.dequeueReusableCell(withIdentifier: CoinInfoTableViewCell.reuseIdentifier, for: indexPath) as? CoinInfoTableViewCell  else {
            return UITableViewCell()
        }
        
        cell.setupViewModel(cellViewModels[indexPath.row])
        return cell
    }
    
    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
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
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] (_) in
                self?.tableView.reloadData()
            }
            .disposed(by: reusableBag)
        
        viewModel
            .headerFooterViewModel
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [weak self] (headerViewModel) in
                (self?.tableView.tableHeaderView as? CoinsInfoListHeaderView)?.setupViewModel(headerViewModel)
            }
            .disposed(by: reusableBag)
    }
    
    private func configureUIInitialState() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: CoinInfoTableViewCell.nibFileName, bundle: nil), forCellReuseIdentifier: CoinInfoTableViewCell.reuseIdentifier)
        
        // Setting header view
        let header  = CoinsInfoListHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        let viewModel = viewModel?.headerFooterViewModel.value
        header.setupViewModel(viewModel)
        tableView.tableHeaderView = header
    }
}
