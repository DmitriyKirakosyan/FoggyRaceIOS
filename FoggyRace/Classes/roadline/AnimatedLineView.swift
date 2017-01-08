//
//  AnimatedLineView.swift
//  FoggyRace
//
//  Created by Dmitriy Kirakosyan on 20/02/2015.
//  Copyright (c) 2015 Glowman. All rights reserved.
//

import UIKit


class AnimatedLineView: UIView {
    var line1: UIView!
    var line2: UIView!
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        line1 = self.createLine()
//        line1.frame.origin = self.frame.origin
        line2 = self.createLine()
        line2.frame.origin.y = -self.frame.size.height + 4
        
        self.addSubview(line1)
        self.addSubview(line2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animate() {
        UIView.animate(withDuration: self.getFallingInterval(), delay: 0, options: [UIViewAnimationOptions.repeat, .curveLinear],
            animations: {
                self.line1.frame.origin.y = self.frame.size.height
            }, completion: { Finished in
                
            }
        )
        
        UIView.animate(withDuration: self.getFallingInterval(), delay: 0, options: [UIViewAnimationOptions.repeat, .curveLinear],
            animations: {
                self.line2.frame.origin.y = 4
            }, completion: { Finished in
                
            }
        )

    }

    func getFallingInterval() -> TimeInterval {
        return 3
    }

    func createLine() -> UIImageView {
        let image = UIImage(named: "line.png")
        let result = UIImageView(image: image);
        result.frame.size = self.frame.size;
        
        return result
    }

}
