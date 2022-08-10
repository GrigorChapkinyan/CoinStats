//
//  CoinsInfoListView.swift
//  CoinStats
//
//  Created by Grigor Chapkinyan on 10.08.22.
//

import UIKit
import RxCocoa

class CoinsInfoListView: UIView {
    // MARK: - Outlets
    
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("CoinsInfoListView", owner: self, options: nil)
        contentView.fixInView(self)
    }
    
    // MARK: - Private API
    
    
}
