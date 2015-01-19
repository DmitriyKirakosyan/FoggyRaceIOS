//
//  FogView.swift
//  FoggyRace
//
//  Created by Dmitriy Kirakosyan on 5/11/2014.
//  Copyright (c) 2014 Glowman. All rights reserved.
//

import UIKit

class FogView: UIImageView {
    
    var animationMinX: CGFloat = 0
    var animationMaxX: CGFloat = 0
    
    var stopped: Bool = false

    convenience init(animationMinX: CGFloat, animationMaxX: CGFloat) {
        self.init()
        self.animationMinX = animationMinX
        self.animationMaxX = animationMaxX
    }
    
    override init() {
        super.init(image: UIImage(named: "6041_Stone.png"))
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func stop() {
        stopped = true
        self.frame.origin = self.layer.presentationLayer().frame.origin
        self.layer.removeAllAnimations()
    }
    
    func run() {
        stopped = false
        if let container = self.superview {
            self.frame.origin = CGPoint(x: container.frame.size.width/2 - self.frame.size.width/2, y: self.frame.origin.y)
        }
        UIView.animateWithDuration(3, delay: 0, options: nil, animations: {

                self.frame.origin.x = (self.animationMinX - self.frame.size.width/2)
            }, completion: { Finished in
                if !self.stopped { self.startAnimationLoop() }
            }
        )
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
