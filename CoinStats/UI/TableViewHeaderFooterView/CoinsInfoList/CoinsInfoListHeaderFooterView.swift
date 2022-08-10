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
    
    // MARK: - View Life Cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureMiddleLabelXCenterConstraint()
    }
    
    // MARK: - Private API
    
    private func configureMiddleLabelXCenterConstraint() {
        let newXCenterMultiplier = Utils.getXAxisCenterConstraintCalculatedMultiplier(parentView: contentView, childView: middleLabel, leadingConstraintMultiplier: Constants.middleRowLeadingPositionPortion)
        
        // If the calculated and existing multipliers are the same,
        // we must return, for avoiding recursion
        guard newXCenterMultiplier != middleLabelXCenterConstraint.multiplier else {
            return
        }
        
        let newConstraintTemp = middleLabelXCenterConstraint.constraintWithMultiplier(newXCenterMultiplier)
        middleLabelXCenterConstraint.isActive = false
        newConstraintTemp.isActive = true
        middleLabelXCenterConstraint = newConstraintTemp
    }
}
