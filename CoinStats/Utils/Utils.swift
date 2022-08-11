//
//  Utils.swift
//  CoinStats
//
//  Created by Grigor Chapkinyan on 10.08.22.
//

import Foundation
import UIKit

struct Utils {
    static func changeDoublePrecision(initialDouble: Double, precision: Int) -> Double {
        return Double(round(pow(10, Double(precision)) * initialDouble) / pow(10, Double(precision)))
    }
}
