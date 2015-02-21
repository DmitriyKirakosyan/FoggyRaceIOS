//
//  ObstacleBehaviour.swift
//  FoggyRace
//
//  Created by Dmitriy Kirakosyan on 6/11/2014.
//  Copyright (c) 2014 Glowman. All rights reserved.
//

import UIKit

class ObstacleBehaviour: UIView {
    var roadView: UIView!
    var linesNum = 0
    var obstacles: [UIView] = []
    
    let OBSTACLE_OFFSET: CGFloat = 15
    
    var stopped: Bool = true
    
    let fastestFalling: CGFloat = 1.5
    var currentFallingSpeed: CGFloat = 0
    let REDUCE_FALLING_SPEED: CGFloat = 0.1
    let START_FALLING_SPEED: CGFloat = 3.5
    
    var currentSpeed: CGFloat = 0
    var lowestSpeed: CGFloat = 0.8
    let REDUCE_SPEED_FACTOR: CGFloat = 0.01
    let START_SPEED: CGFloat = 1.2
    var reduceSpeedTimer: NSTimer?
    
    var fallsNum: Int = 0
    
    func DEGREES_TO_RADIANS(x: Float) -> Float { return Float(M_PI) * x / 180.0 }

    
    convenience init(roadView: UIView, linesNum: Int) {
        self.init()
        self.roadView = roadView
        self.linesNum = linesNum
        self.frame.origin = roadView.frame.origin
        roadView.addSubview(self)
    }
    
    override init() {
        super.init()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hide() {
        self.layer.removeAllAnimations()
        UIView.animateWithDuration(0.1, animations: {
            self.alpha = 0
        })
    }
    
    func show() {
        self.layer.removeAllAnimations()
        UIView.animateWithDuration(0.1, animations: {
            self.alpha = 1
        })
    }
    
    func testHitRect(rect: CGRect) -> Bool {
        var result: Bool = false
        for obstacle in obstacles {
            if (obstacle.layer.presentationLayer() != nil &&
                obstacle.layer.presentationLayer().frame.intersects(rect)) {
                result = true
                break
            }
        }
        
        return result
    }
    
    func stop() {
        stopped = true
        for obstacle in obstacles {
            obstacle.frame.origin = obstacle.layer.presentationLayer().frame.origin
            obstacle.layer.removeAllAnimations()
          //  self.removeObstacle(obstacle)

        }
        reduceSpeedTimer?.invalidate()
        reduceSpeedTimer = nil
    }
    
    func run() {
        self.fallsNum = 0
        self.currentFallingSpeed = START_FALLING_SPEED
        self.currentSpeed = START_SPEED
        self.stopped = false
        self.shootObstacle()
        let timerSelector: Selector = Selector("onTimer")
        NSTimer.scheduledTimerWithTimeInterval(self.getTimerInterval(), target: self, selector: timerSelector, userInfo: nil, repeats: false)
        
        self.reduceSpeedTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("reduceSpeed"), userInfo: nil, repeats: true)
    }
    
    func onTimer() {
        if (!stopped) {
            self.shootObstacle()
            let timerSelector: Selector = Selector("onTimer")
            let interval = self.getTimerInterval();
            NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: timerSelector, userInfo: nil, repeats: false)
           // else{
               // NSTimer.scheduledTimerWithTimeInterval(self.getTimerInterval(), target: self, selector: timerSelector, userInfo: nil, repeats: false)
           // }
        }
        
    }
    
    func shootObstacle(){
        var obstacle = self.createObstacle()
        obstacles.append(obstacle)
        
    
        let line: Int = random() % (linesNum+1)
        obstacle.frame.origin.y = -obstacle.frame.size.height
        
        obstacle.frame.origin.x = CGFloat(line) * (roadView.frame.size.width/CGFloat(linesNum+1)) + OBSTACLE_OFFSET
        
//        let random: CGFloat = CGFloat(arc4random()) / CGFloat(UINT32_MAX)
//        let obstacleX = (random * self.roadView.frame.size.width - 100) + 50
//        obstacle.frame.origin.x = obstacleX

        
        self.addSubview(obstacle)
        
        UIView.animateWithDuration(self.getFallingInterval(), delay: 0, options: UIViewAnimationOptions.CurveLinear,
            animations: {
                obstacle.frame.origin.y = self.roadView.frame.size.height
            }, completion: { finished in
                self.removeObstacle(obstacle)
                
            }
        )
    }
    
    
    
    
    func removeObstacle(obstacle: UIView) {
        obstacle.removeFromSuperview()
        self.obstacles.removeAtIndex(find(obstacles, obstacle)!)
        self.fallsNum++
    }
    
    func createObstacle() -> ObstacleView {
        var result = ObstacleView()
        result.transform = CGAffineTransformMakeRotation(CGFloat(self.DEGREES_TO_RADIANS(180)))
        //result.frame.size = CGSize(width: self.getObstacleSize(), height: self.getObstacleSize())
        
        return result
    }
    
    
    
    func getObstacleSize() -> CGFloat {
        return roadView.frame.size.width / CGFloat(linesNum) - OBSTACLE_OFFSET * 2
    }

    func reduceSpeed() {
        currentSpeed -= REDUCE_SPEED_FACTOR
        currentFallingSpeed -= REDUCE_FALLING_SPEED
        if currentSpeed < lowestSpeed { currentSpeed = lowestSpeed }
        if currentFallingSpeed < fastestFalling { currentFallingSpeed = fastestFalling }
    }
    
    func getTimerInterval() -> NSTimeInterval {
        let random: CGFloat = CGFloat(arc4random()) / CGFloat(UINT32_MAX)
        return NSTimeInterval(random * self.currentSpeed)
    }
    
    func getFallingInterval() -> NSTimeInterval {
        return NSTimeInterval(currentFallingSpeed)
    }
}
