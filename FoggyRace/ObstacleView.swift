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
    
    var animationMinX: CGFloat = 0
    var animationMaxX: CGFloat = 0
    
    var stopped: Bool = false
    
    convenience init(animationMinX: CGFloat, animationMaxX: CGFloat) {
        self.init()
        self.animationMinX = animationMinX
        self.animationMaxX = animationMaxX
    }
    
    override init() {
        super.init(image: UIImage(named: "car.png"))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func startAnimationLoop() {
        UIView.animateWithDuration(6, delay: 0, options: .Repeat | .Autoreverse, animations: {
            self.center.x = self.animationMaxX
            //self.frame.origin.x = self.animationMaxX
            }, completion: { Finished in
                if !self.stopped { self.startAnimationLoop() }
            }
        )
    }
}
