//
//  ViewController.swift
//  FoggyRace
//
//  Created by Dmitriy Kirakosyan on 5/11/2014.
//  Copyright (c) 2014 Glowman. All rights reserved.
//


import UIKit
import AVFoundation



class ViewController: UIViewController {
    @IBOutlet weak var roadView: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var obstacleBehaviour: ObstacleBehaviour!
    

    var roadLinesView:  RoadLinesView!

    var moving: Bool = false
    var movingDirection: Int = 0
    var panStartPoint: CGFloat = 0
    
    var carView: UIView!
    var carPosition: Int = 1
    let minCarPosition: Int = 0
    let maxCarPosition: Int = 2
    
    let CAR_SPEED: CGFloat = 6
    let COLUMN_WIDTH: CGFloat = 256
    let ROAD_LINE_NUMS = 3
    let PAN_DISTANCE: CGFloat = 200
    
    let LINES_NUM:Int = 5
    
    var tickTimer: NSTimer?
    
    
    lazy var backgroundMusic: AVAudioPlayer = {
        let url = NSBundle.mainBundle().URLForResource("radio", withExtension: "mp3")
        let player = AVAudioPlayer(contentsOfURL: url, error: nil)
        player.numberOfLoops = -1
        return player
    }()


    
    func DEGREES_TO_RADIANS(x: Float) -> Float { return Float(M_PI) * x / 180.0 }

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundMusic.play()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.startGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startGame() {
        self.runLines()

        //self.createFog()
        self.drawCar()
        self.runObstacles()

        self.addRecognizers()
        self.scheduleTickTimer()
        
        scoreLabel.text = "0"
    }
    
    func restartGame() {
        self.removeRecognizers()
        
        self.carPosition = 1
        carView.frame.origin.x = roadView.frame.size.width/2 - carView.frame.size.width/2
        
        self.obstacleBehaviour.run()
        self.addRecognizers()
        self.scheduleTickTimer()
        
        scoreLabel.text = "0"
    }
    
    func addRecognizers() {
        var panRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
        var tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        
        panRecognizer.maximumNumberOfTouches = 1
        panRecognizer.minimumNumberOfTouches = 1
        
        roadView.addGestureRecognizer(panRecognizer)
        roadView.addGestureRecognizer(tapRecognizer)
    }
    
    func removeRecognizers() {
        if let recognizers = self.roadView.gestureRecognizers {
            for recognizer in recognizers {
                self.roadView.removeGestureRecognizer(recognizer as UIGestureRecognizer)
            }
        }
    }
    
       
    func runObstacles() {
        obstacleBehaviour = ObstacleBehaviour(roadView: self.roadView, linesNum: LINES_NUM)
        obstacleBehaviour.run()
    }
    
    func runLines(){
        roadLinesView = RoadLinesView(frame: self.roadView.frame, linesNum: LINES_NUM)
        roadLinesView.userInteractionEnabled = false

        self.roadView.addSubview(roadLinesView);
        roadLinesView.run()
    }
    
    func scheduleTickTimer() {
        tickTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("onTick"), userInfo: nil, repeats: true)
    }
    
    func drawCar() {
        var image = UIImage(named: "hero.png")
        carView = UIImageView(image: image)
        carView.frame.origin.x = roadView.frame.size.width/2 - carView.frame.size.width/2
        carView.frame.origin.y = roadView.frame.height - carView.frame.size.height - 10
        
        roadView.addSubview(carView);
    }

    
    func handlePan(pan: UIPanGestureRecognizer) {

        
        //self.carView.transform = CGAffineTransformMakeRotation(CGFloat(self.DEGREES_TO_RADIANS(-30)))

        let prevDirection = movingDirection
        if pan.state == .Changed {
            movingDirection = pan.velocityInView(self.view).x < 0 ? -1 : 1
        }
        if pan.state == .Ended {
            self.obstacleBehaviour.show()
            movingDirection = 0
            moving = false
        }
        else if pan.state == .Began {
            self.obstacleBehaviour.hide()
            moving = true
        }
        
        let realDistance = self.view.frame.size.width/2 - 50
        let centerPosition = self.view.frame.size.width/2
        if (pan.state == .Began)
        {
            self.obstacleBehaviour.hide()
            
            let currentCarPosition = self.carView.center.x - pan.locationInView(self.view).x
            let virtualPosition = currentCarPosition / realDistance * PAN_DISTANCE
            self.panStartPoint = pan.locationInView(self.view).x + virtualPosition
        }
    
        if movingDirection != 0
        {
            let currentPanPosition = pan.locationInView(self.view).x
            var currentDistance = currentPanPosition - self.panStartPoint
            if currentDistance < -PAN_DISTANCE { currentDistance = -PAN_DISTANCE }
            if currentDistance > PAN_DISTANCE { currentDistance = PAN_DISTANCE }
            let virtualPosition = currentDistance / PAN_DISTANCE
            let carNewX = centerPosition + (virtualPosition * realDistance)
            //moveCarToX(carNewX)
        }
        
        
        //self.moveCar(-1)

    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.obstacleBehaviour.hide()
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if !self.moving { self.obstacleBehaviour.show() }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        if !self.moving  { self.obstacleBehaviour.show() }
    }
    
    func handleTap(tap: UITapGestureRecognizer) {
    }
    
    func normalizeCarRotation()
    {
        self.carView.transform = CGAffineTransformMakeRotation(CGFloat(self.DEGREES_TO_RADIANS(0)))
    }
    
    func stopCar() {
        self.normalizeCarRotation()
        
        let layer:CALayer = self.carView.layer.presentationLayer() as CALayer;
        
        self.carView.layer.removeAllAnimations()
        self.carView.frame.origin = layer.frame.origin;
    }
    func moveCar(direction: Int) {
        self.carView.frame.origin.x += 5 * CGFloat(direction)
        
//        self.stopCar()
//        let nextX: CGFloat = CGFloat(self.carPosition) * COLUMN_WIDTH + COLUMN_WIDTH/2 - self.carView.frame.size.width/2
//        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
//            self.carView.frame.origin.x = nextX
//        }, completion: nil)
    }
    func moveCarToX(x: CGFloat) {
        self.carView.center.x = x
    }
    
    func onTick() {
        if (carView.layer.presentationLayer() != nil && obstacleBehaviour.testHitRect(carView.layer.presentationLayer().frame)) {
            self.gameOver()
        } else {
            self.scoreLabel.text = String(self.obstacleBehaviour.fallsNum)
            
            if (self.moving)
            {
                self.carView.center.x += CGFloat(self.movingDirection) * CAR_SPEED
                if self.carView.center.x < 50 { self.carView.center.x = 50 }
                let rightEdge = self.view.frame.size.width - 50
                if self.carView.center.x > rightEdge { self.carView.center.x = rightEdge }
                
            }
        }
    }
    
    func gameOver() {
        tickTimer!.invalidate()
        tickTimer = nil
        self.moving = false
        self.movingDirection = 0

        self.stopAllAnimations()
        self.removeRecognizers()

        var tap = UITapGestureRecognizer(target :self, action:Selector("restartGame"));
        self.roadView.addGestureRecognizer(tap)
    }
    
    func stopAllAnimations() {
        self.stopCar()
        self.obstacleBehaviour.stop()
    }

}


