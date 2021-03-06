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
    
    let images: [String] = ["obstacle1.png", "obstacle2.png", "obstacle3.png"];
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.image = UIImage(named: images[Int(arc4random() % UInt32(images.count))])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func runRotationAction() {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(.pi * 2.0)
        rotateAnimation.duration = 5.0
        rotateAnimation.repeatCount = MAXFLOAT
        
        self.layer.add(rotateAnimation, forKey: nil)
    }
    
}
