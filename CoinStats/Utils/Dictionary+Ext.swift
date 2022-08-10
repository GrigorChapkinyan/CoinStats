//
//  Dictionary+Ext.swift
//  CoinStats
//
//  Created by Grigor Chapkinyan on 10.08.22.
//

import Foundation

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}
