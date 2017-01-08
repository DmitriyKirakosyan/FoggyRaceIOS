//
//  HeroView.swift
//  FoggyRace
//
//  Created by Dmitriy on 11/27/15.
//  Copyright © 2015 Glowman. All rights reserved.
//

import Foundation
import UIKit

class HeroView: UIImageView {
    
    init() {
        super.init(image: UIImage(named: "car0001.png"))
        
        self.animationImages = []
        for index in 0 ..< 10 {
            let frameName = String(format: "car%04d", index+1)
            self.animationImages?.append(UIImage(named: frameName)!)
        }
        self.animationDuration = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
