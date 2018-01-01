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
    
    var stopped: Bool = true
    
    let fastestFalling: CGFloat = 1.5
    var currentFallingSpeed: CGFloat = 0
    let REDUCE_FALLING_SPEED: CGFloat = 0.1
    let START_FALLING_SPEED: CGFloat = 3.5

    var currentSpeed: CGFloat = 0
    var lowestSpeed: CGFloat = 0.8
    let REDUCE_SPEED_FACTOR: CGFloat = 0.01
    let START_SPEED: CGFloat = 1.2
    var reduceSpeedTimer: Timer?
    
    var fallsNum: Int = 0
    
    fileprivate var _patternFactory: ObstaclePatternFactory;
    fileprivate var _currentPattern: RoadPattern?;
    fileprivate var _currentPatternLine: Int = 0;
    
    
    func DEGREES_TO_RADIANS(_ x: Float) -> Float { return .pi * x / 180.0 }

    
    convenience init(roadView: UIView, linesNum: Int) {
        self.init()
        self.roadView = roadView
        self.linesNum = linesNum
        self.frame.size = roadView.frame.size
        roadView.addSubview(self)
    }
    
    init() {
        _patternFactory = ObstaclePatternFactory()
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hide() {
//        self.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.8, animations: {
            self.alpha = 0
        })
    }
    
    func show() {
//        self.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.8, animations: {
            self.alpha = 1
        })
    }
    
    /** Test if some obstacle hits given rect
    */
    func testHitRect(_ rect: CGRect) -> Bool {
        var result: Bool = false
        for obstacle in obstacles {
            guard let presentationLayer = obstacle.layer.presentation() else { continue }
            
            var frameForCheck = presentationLayer.frame
            frameForCheck.size = CGSize(width: frameForCheck.size.width/2, height: frameForCheck.size.height/2)
            frameForCheck.origin = CGPoint(x: frameForCheck.origin.x + frameForCheck.size.width/2, y: frameForCheck.origin.y + frameForCheck.size.height/2)
            
            if frameForCheck.intersects(rect) {
                result = true
                print("frame to check : \(frameForCheck), car frame : \(rect)")
                break
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

            if let presentationLayer = obstacle.layer.presentation() {
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
        let timerSelector: Selector = #selector(ObstacleBehaviour.onTimer)
        Timer.scheduledTimer(timeInterval: self.getObstacleLineTimeInterval(), target: self, selector: timerSelector, userInfo: nil, repeats: false)
        
        self.reduceSpeedTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ObstacleBehaviour.reduceSpeed), userInfo: nil, repeats: true)
    }
    
    @objc func onTimer() {
        if (!stopped) {
            self.shootObstacle()
            let timerSelector: Selector = #selector(ObstacleBehaviour.onTimer)
            let interval = self.getObstacleLineTimeInterval();
            Timer.scheduledTimer(timeInterval: interval, target: self, selector: timerSelector, userInfo: nil, repeats: false)
        }
        
    }
    
    func shootObstacle(){
        if _currentPattern == nil || !_currentPattern!.containsLine(_currentPatternLine) {
            _currentPattern = _patternFactory.getRandomPattern()
            _currentPatternLine = 0;
        }

        let obstaclePositions = _currentPattern!.getObstaclePositionsForLine(_currentPatternLine)
        _currentPatternLine += 1
        
        var obstacleFrame = self.getObstacleFrame()
        obstacleFrame.origin.y = -obstacleFrame.size.height
        
        let roadWidth: CGFloat = roadView.frame.size.width
        let roadFieldWidth: CGFloat = roadWidth/CGFloat(linesNum)

        for position: Int in obstaclePositions
        {
//            obstacleFrame.origin.x = CGFloat(position) * (roadView.frame.size.width/CGFloat(linesNum)) + OBSTACLE_OFFSET
            let obstacle = self.createObstacle(obstacleFrame)
            obstacle.center.x = CGFloat(position) * roadFieldWidth + roadFieldWidth / 2
            obstacles.append(obstacle)
            
            self.addSubview(obstacle)
            
            UIView.animate(withDuration: TimeInterval(self.getFallingSpeed()), delay: 0, options: UIViewAnimationOptions.curveLinear,
                animations: {
                    obstacle.frame.origin.y = self.roadView.frame.size.height
                }, completion: { finished in
                    if obstacle.frame.origin.y > self.roadView.frame.size.height-20 {
                        self.removeObstacle(obstacle)
                    }
                    
                }
            )
        }
    }
    
    
    
    
    func removeObstacle(_ obstacle: UIView) {
        obstacle.removeFromSuperview()
        self.obstacles.remove(at: obstacles.index(of: obstacle)!)
        self.fallsNum += 1
    }
    
    func createObstacle(_ frame: CGRect) -> ObstacleView {
        let result = ObstacleView(frame: frame)
        
        return result
    }
    
    
    
    func getObstacleFrame() -> CGRect {
        let obstacleWidth = roadView.frame.size.width / CGFloat(linesNum)
        
        return CGRect(x: 0, y: 0, width: obstacleWidth, height: obstacleWidth)
    }

    @objc func reduceSpeed() {
        currentSpeed -= REDUCE_SPEED_FACTOR
        currentFallingSpeed -= REDUCE_FALLING_SPEED
        
        if currentSpeed < lowestSpeed { currentSpeed = lowestSpeed }
        if currentFallingSpeed < fastestFalling { currentFallingSpeed = fastestFalling }
    }
    
    func getObstacleLineTimeInterval() -> TimeInterval {
        let timeInterval: CGFloat = currentFallingSpeed /
                                    ((self.roadView.frame.size.height + 20) / self.getObstacleFrame().height);
        return TimeInterval(timeInterval)
    }
    
    func getFallingSpeed() -> CGFloat {
        return currentFallingSpeed
    }
    

}
