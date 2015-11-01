//
//  ObstacleView.swift
//  FoggyRace
//
//  Created by Kuznetsov Mikhail on 24.12.14.
//  Copyright (c) 2014 Glowman. All rights reserved.
//

import Foundation
import UIKit

class ObstacleView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.image = UIImage(named: "enemy.png")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
