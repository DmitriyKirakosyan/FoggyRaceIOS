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
    
    let OBSTACLE_OFFSET: CGFloat = 70
    
    var stopped: Bool = true
    
    var lowestSpeed: CGFloat = 4
    let REDUCE_SPEED_FACTOR: CGFloat = 0.1
    var reduceSpeedTimer: NSTimer?
    
    var fallsNum: Int = 0
    
    convenience init(roadView: UIView, linesNum: Int) {
        self.init()
        self.roadView = roadView
        self.linesNum = linesNum
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
        self.lowestSpeed = 4
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
            NSTimer.scheduledTimerWithTimeInterval(self.getTimerInterval(), target: self, selector: timerSelector, userInfo: nil, repeats: false)
        }
    }
    
    func shootObstacle(){
        var obstacle = self.createObstacle()
        obstacles.append(obstacle)
        
            
        let line: Int = random() % linesNum
        obstacle.frame.origin.y = -obstacle.frame.size.height
        obstacle.frame.origin.x = CGFloat(line) * (roadView.frame.size.width/CGFloat(linesNum)) + OBSTACLE_OFFSET
        roadView.addSubview(obstacle)
        
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
        result.frame.size = CGSize(width: self.getObstacleSize(), height: self.getObstacleSize())
        
        return result
    }
    
    
    
    func getObstacleSize() -> CGFloat {
        return roadView.frame.size.width / CGFloat(linesNum) - OBSTACLE_OFFSET * 2
    }

    func reduceSpeed() {
        lowestSpeed -= REDUCE_SPEED_FACTOR
    }
    
    func getTimerInterval() -> NSTimeInterval {
        let random: CGFloat = CGFloat(arc4random()) / CGFloat(UINT32_MAX)
        return NSTimeInterval(random * self.lowestSpeed)
    }
    
    func getFallingInterval() -> NSTimeInterval {
        return 3
    }
}
