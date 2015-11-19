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
    
    private var _patternFactory: ObstaclePatternFactory;
    private var _currentPattern: RoadPattern?;
    private var _currentPatternLine: Int = 0;
    
    
    func DEGREES_TO_RADIANS(x: Float) -> Float { return Float(M_PI) * x / 180.0 }

    
    convenience init(roadView: UIView, linesNum: Int) {
        self.init()
        self.roadView = roadView
        self.linesNum = linesNum
        self.frame.origin = roadView.frame.origin
        roadView.addSubview(self)
    }
    
    init() {
        _patternFactory = ObstaclePatternFactory()
        super.init(frame: CGRectZero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hide() {
//        self.layer.removeAllAnimations()
        UIView.animateWithDuration(0.8, animations: {
            self.alpha = 0
        })
    }
    
    func show() {
//        self.layer.removeAllAnimations()
        UIView.animateWithDuration(0.8, animations: {
            self.alpha = 1
        })
    }
    
    /** Test if some obstacle hits given rect
    */
    func testHitRect(rect: CGRect) -> Bool {
        var result: Bool = false
        for obstacle in obstacles {
            if (obstacle.layer.presentationLayer() != nil) {
                var frameForCheck = obstacle.layer.presentationLayer()!.frame
                frameForCheck.size = CGSize(width: frameForCheck.size.width/2, height: frameForCheck.size.height/2)
                frameForCheck.origin = CGPoint(x: frameForCheck.origin.x + frameForCheck.size.width/2, y: frameForCheck.origin.y + frameForCheck.size.height/2)
                
                if frameForCheck.intersects(rect) {
                    result = true
                    break
                }
            }
        }
        
        return result
    }
    
    func clean() {
        for obstacle in obstacles {
            self.removeObstacle(obstacle)
        }
    }
    
    func stop() {
        stopped = true
        for obstacle in obstacles {

            if let presentationLayer = obstacle.layer.presentationLayer() {
                obstacle.frame.origin = presentationLayer.frame.origin
                
                obstacle.layer.removeAllAnimations()
            }
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
        NSTimer.scheduledTimerWithTimeInterval(self.getObstacleLineTimeInterval(), target: self, selector: timerSelector, userInfo: nil, repeats: false)
        
        self.reduceSpeedTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("reduceSpeed"), userInfo: nil, repeats: true)
    }
    
    func onTimer() {
        if (!stopped) {
            self.shootObstacle()
            let timerSelector: Selector = Selector("onTimer")
            let interval = self.getObstacleLineTimeInterval();
            NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: timerSelector, userInfo: nil, repeats: false)
        }
        
    }
    
    func shootObstacle(){
        if _currentPattern == nil || !_currentPattern!.containsLine(_currentPatternLine) {
            _currentPattern = _patternFactory.getRandomPattern()
            _currentPatternLine = 0;
        }

        let obstaclePositions = _currentPattern!.getObstaclePositionsForLine(_currentPatternLine)
        _currentPatternLine++
        
        var obstacleFrame = self.getObstacleFrame()
        obstacleFrame.origin.y = -obstacleFrame.size.height

        for position: Int in obstaclePositions
        {
            obstacleFrame.origin.x = CGFloat(position) * (roadView.frame.size.width/CGFloat(linesNum+1)) + OBSTACLE_OFFSET
            let obstacle = self.createObstacle(obstacleFrame)
            obstacles.append(obstacle)
            
            self.addSubview(obstacle)
            
            UIView.animateWithDuration(NSTimeInterval(self.getFallingSpeed()), delay: 0, options: UIViewAnimationOptions.CurveLinear,
                animations: {
                    obstacle.frame.origin.y = self.roadView.frame.size.height
                }, completion: { finished in
                    if obstacle.frame.origin.y > self.roadView.frame.size.height-20 {
                        self.removeObstacle(obstacle)
                    }
                    
                }
            )
            
            obstacle.runRotationAction()
        }
    }
    
    
    
    
    func removeObstacle(obstacle: UIView) {
        obstacle.removeFromSuperview()
        self.obstacles.removeAtIndex(obstacles.indexOf(obstacle)!)
        self.fallsNum++
    }
    
    func createObstacle(frame: CGRect) -> ObstacleView {
        let result = ObstacleView(frame: frame)
        result.transform = CGAffineTransformMakeRotation(CGFloat(self.DEGREES_TO_RADIANS(180)))
        //result.frame.size = CGSize(width: self.getObstacleSize(), height: self.getObstacleSize())
        
        return result
    }
    
    
    
    func getObstacleSize() -> CGFloat {
        return roadView.frame.size.width / CGFloat(linesNum) - OBSTACLE_OFFSET * 2
    }
    
    func getObstacleFrame() -> CGRect {
        return CGRect(x: 0, y: 0, width: 100, height: 100)
    }

    func reduceSpeed() {
        currentSpeed -= REDUCE_SPEED_FACTOR
        currentFallingSpeed -= REDUCE_FALLING_SPEED
        
        if currentSpeed < lowestSpeed { currentSpeed = lowestSpeed }
        if currentFallingSpeed < fastestFalling { currentFallingSpeed = fastestFalling }
    }
    
    func getObstacleLineTimeInterval() -> NSTimeInterval {
        let timeInterval: CGFloat = currentFallingSpeed /
                                    ((self.roadView.frame.size.height + 20) / self.getObstacleFrame().height);
        return NSTimeInterval(timeInterval)
    }
    
    func getFallingSpeed() -> CGFloat {
        return currentFallingSpeed
    }
    

}
