//
//  LineBehaviour.swift
//  FoggyRace
//
//  Created by Kuznetsov Mikhail on 01.01.15.
//  Copyright (c) 2015 Glowman. All rights reserved.
//

import UIKit
class RoadLinesView: UIView {
    
    
    //var LineBehaviourView: UIView!
   
    
    var line1: [UIImageView] = [];
    var line2: [UIImageView] = [];
    
    var stopped: Bool = true
    
    var lowestSpeed: CGFloat = 4
    let REDUCE_SPEED_FACTOR: CGFloat = 0.1
    var reduceSpeedTimer: NSTimer?
    
    var fallsNum: Int = 0
    
    var firstLine: UIImageView!
    var secondLine: UIImageView!
    var thirdLine: UIImageView!
    var fourthLine: UIImageView!
    
    
    override init() {
        super.init()

        firstLine = self.createLine()
        secondLine = self.createLine()
        thirdLine = self.createLine()
        fourthLine = self.createLine()
        //self.giveLinePosition()

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func stop() {
        stopped = true
        for line in line1 {
            self.frame.origin = self.layer.presentationLayer().frame.origin

            line.layer.removeAllAnimations()
        }
        for line in line2 {
            self.frame.origin = self.layer.presentationLayer().frame.origin

            line.layer.removeAllAnimations()
        }
        reduceSpeedTimer?.invalidate()
        reduceSpeedTimer = nil
    }
    
    func run() {
        self.fallsNum = 0
        self.lowestSpeed = 4
        self.stopped = false
        self.giveLinePosition()

        
        self.animateLine()
        
    }
    
   
    
    func giveLinePosition(){
        line1.append(firstLine)
        line1.append(thirdLine)
        line1.append(secondLine)
        line1.append(fourthLine)
        
        firstLine.frame.size =  CGSize(width: firstLine.frame.size.width, height: self.frame.size.height)
        thirdLine.frame.size =  CGSize(width: thirdLine.frame.size.width, height: self.frame.size.height)
        secondLine.frame.size =  CGSize(width: secondLine.frame.size.width, height: self.frame.size.height)
        fourthLine.frame.size =  CGSize(width: fourthLine.frame.size.width, height: self.frame.size.height)

        
        
        firstLine.frame.origin.y = 0
        firstLine.frame.origin.x = (self.frame.size.width/3) - firstLine.frame.size.width/2
        self.addSubview(firstLine)
        
        thirdLine.frame.origin.y = -thirdLine.frame.size.height - 4
        thirdLine.frame.origin.x = (self.frame.size.width/3) - thirdLine.frame.size.width/2
        self.addSubview(thirdLine)
        
        secondLine.frame.origin.y = 0
        secondLine.frame.origin.x = (self.frame.size.width/3 * 2) - secondLine.frame.size.width/2
        self.addSubview(secondLine)
        
        fourthLine.frame.origin.y = -fourthLine.frame.size.height - 4
        fourthLine.frame.origin.x = (self.frame.size.width/3 * 2) - fourthLine.frame.size.width/2
        self.addSubview(fourthLine)
    }
  

    func animateLine() {
        
        UIView.animateWithDuration(self.getFallingInterval(), delay: 0, options: UIViewAnimationOptions.Repeat | .CurveLinear,
            animations: {
                self.firstLine.frame.origin.y = self.frame.size.height
            }, completion: { Finished in
                
            }
        )
        
        UIView.animateWithDuration(self.getFallingInterval(), delay: 0, options: UIViewAnimationOptions.Repeat | .CurveLinear,
            animations: {
                self.thirdLine.frame.origin.y = -4
            }, completion: { Finished in
                
            }
        )
        
        UIView.animateWithDuration(self.getFallingInterval(), delay: 0, options: UIViewAnimationOptions.Repeat | .CurveLinear,
            animations: {
                self.secondLine.frame.origin.y = self.frame.size.height
            }, completion: { Finished in
                
            }
        )
        
        UIView.animateWithDuration(self.getFallingInterval(), delay: 0, options: UIViewAnimationOptions.Repeat | .CurveLinear,
            animations: {
                self.fourthLine.frame.origin.y = -4
            }, completion: { Finished in
                
            }
        )
    }
   
    
    func createLine() -> UIImageView {
        let image = UIImage(named: "line.png")
        var result = UIImageView(image: image);
        
        
        
        return result
    } 
    
    
  // func getLineSize() -> CGFloat {
   ////     return roadView.frame.size.width / CGFloat(linesNum) - OBSTACLE_OFFSET * 2
   /// }
    
    func reduceSpeed() {
        lowestSpeed -= REDUCE_SPEED_FACTOR
    }
    
    func getTimerInterval() -> NSTimeInterval {
       // let random: CGFloat = CGFloat(arc4random()) / CGFloat(UINT32_MAX)
        //return NSTimeInterval(self.getFallingInterval() * self.lowestSpeed)
        return 3

    }
    
    func getFallingInterval() -> NSTimeInterval {
        return 3
    }
}
