//
//  RootNavigationController.swift
//  CoinStats
//
//  Created by Grigor Chapkinyan on 09.08.22.
//

import UIKit

class RootNavigationController: UINavigationController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            return .landscape
        }
        else {
            return .portrait
        }
    }
  
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
