//
//  Utils.swift
//  CoinStats
//
//  Created by Grigor Chapkinyan on 10.08.22.
//

import Foundation
import UIKit

struct Utils {
    static func getXAxisCenterConstraintCalculatedMultiplier(parentView: UIView, childView:UIView, leadingConstraintMultiplier: CGFloat) -> CGFloat {
        let leadingCorrectDistance = leadingConstraintMultiplier * parentView.bounds.width
        let xCenterDistance = leadingCorrectDistance + (childView.bounds.width / 2)
        let newXCenterMultiplier = xCenterDistance / (parentView.bounds.width / 2)
        
        return newXCenterMultiplier
    }
}
