//
//  CoinsInfoListHeaderFooterView.swift
//  CoinStats
//
//  Created by Grigor Chapkinyan on 10.08.22.
//

import UIKit

class CoinsInfoListHeaderFooterView: UITableViewHeaderFooterView {
    // MARK: - Outlets
    
    @IBOutlet private weak var middleLabelXCenterConstraint: NSLayoutConstraint!
    @IBOutlet private weak var middleLabel: UILabel!
    
    // MARK: Public Properties
    
    static let reusieIdentifier = "CoinsInfoListHeaderFooterView"
    static let nibFileName = "CoinsInfoListHeaderFooterView"
}
