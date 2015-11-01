//
//  ViewController.swift
//  FoggyRace
//
//  Created by Dmitriy Kirakosyan on 5/11/2014.
//  Copyright (c) 2014 Glowman. All rights reserved.
//


import UIKit
import AVFoundation



class ViewController: UIViewController, BonusManagerDelegate, EnergyManagerDelegate {
    @IBOutlet weak var roadView: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var obstacleBehaviour: ObstacleBehaviour!
    var bonusManager: BonusManager!
    var energyManager: EnergyManager!

    var roadLinesView:  RoadLinesView!

    var moving: Bool = false
    var movingDirection: Int = 0
    var panStartPoint: CGFloat = 0
    
    var carView: UIView!
    var carField: Int = 3
    let minCarPosition: Int = 0
    let maxCarPosition: Int = 5
    
    let CAR_SWIPE_SPEED: CGFloat = 0.1
    
    let CAR_SPEED: CGFloat = 6
    let COLUMN_WIDTH: CGFloat = 256
    let ROAD_LINE_NUMS = 3
    let PAN_DISTANCE: CGFloat = 200
    
    let FIELDS_NUM:Int = 6
    
    var tickTimer: NSTimer?
    
    
    lazy var backgroundMusic: AVAudioPlayer = {
        let url = NSBundle.mainBundle().URLForResource("radio", withExtension: "mp3")
        let player = try? AVAudioPlayer(contentsOfURL: url!)
        player!.numberOfLoops = -1
        return player!
    }()


    
    func DEGREES_TO_RADIANS(x: Float) -> Float { return Float(M_PI) * x / 180.0 }

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundMusic.play()
        
        self.bonusManager = BonusManager(stageView: self.view, fieldsNum: FIELDS_NUM)
        self.bonusManager.delegate = self
        self.energyManager = EnergyManager(stageView: self.view)
        self.energyManager.delegate = self
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
        self.runManagers()
        self.addRecognizers()
        self.scheduleTickTimer()
        
        scoreLabel.text = "0"
    }
    
    func restartGame() {
        self.removeRecognizers()
        
        self.obstacleBehaviour.clean()
        
        self.carField = 3
        self.updateHeroPosition()
        
        self.obstacleBehaviour.run()
        self.runManagers()
        self.addRecognizers()
        self.scheduleTickTimer()
        
        scoreLabel.text = "0"
    }
    
    func runManagers() {
        self.bonusManager.run()
        self.energyManager.setFullEnergy()
        self.energyManager.run()
    }
    
    func addRecognizers() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        let swipeRight = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))

        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left;
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right;
        
        roadView.addGestureRecognizer(swipeLeft)
        roadView.addGestureRecognizer(swipeRight)
    }
    
    func removeRecognizers() {
        if let recognizers = self.roadView.gestureRecognizers {
            for recognizer in recognizers {
                self.roadView.removeGestureRecognizer(recognizer as UIGestureRecognizer)
            }
        }
    }
       
    func runObstacles() {
        obstacleBehaviour = ObstacleBehaviour(roadView: self.roadView, linesNum: FIELDS_NUM-1)
        obstacleBehaviour.run()
    }
    
    func runLines(){
        roadLinesView = RoadLinesView(frame: self.roadView.frame, linesNum: FIELDS_NUM-1)
        roadLinesView.userInteractionEnabled = false

        self.roadView.addSubview(roadLinesView);
        roadLinesView.run()
    }
    
    func scheduleTickTimer() {
        tickTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("onTick"), userInfo: nil, repeats: true)
    }
    
    func drawCar() {
        let image = UIImage(named: "hero.png")
        carView = UIImageView(image: image)
        carView.frame.origin.x = roadView.frame.size.width/2 - carView.frame.size.width/2
        
        self.updateHeroPosition()
        carView.frame.origin.y = roadView.frame.height - carView.frame.size.height - 10
        
        roadView.addSubview(carView);
    }

    
    func handleSwipe(swipe: UISwipeGestureRecognizer) {
        let direction = swipe.direction == UISwipeGestureRecognizerDirection.Left ? -1 : 1
        self.moveCar(direction)
        let rotationSpeed = NSTimeInterval(CAR_SWIPE_SPEED)
        UIView.animateWithDuration(rotationSpeed,
            delay: 0.0,
            options: [],
            animations: {
                self.carView.transform = CGAffineTransformMakeRotation(CGFloat(self.DEGREES_TO_RADIANS(Float(direction) * 30)))
            },
            completion: { finished in
                UIView.animateWithDuration(rotationSpeed,
                    delay: 0.0,
                    options: [],
                    animations: {
                        self.carView.transform = CGAffineTransformMakeRotation(CGFloat(self.DEGREES_TO_RADIANS(0)))
                    },
                    completion: nil
                )
            }
        )
    }
    
    func normalizeCarRotation()
    {
        self.carView.transform = CGAffineTransformMakeRotation(CGFloat(self.DEGREES_TO_RADIANS(0)))
    }
    
    func stopCar() {
        self.normalizeCarRotation()
        
        let layer:CALayer = self.carView.layer.presentationLayer() as! CALayer;
        
        self.carView.layer.removeAllAnimations()
        self.carView.frame.origin = layer.frame.origin;
    }
    func moveCar(direction: Int) {
      //  self.carView.frame.origin.x += 5 * CGFloat(direction)
        self.carField += direction
        if self.carField > FIELDS_NUM-1 { self.carField = FIELDS_NUM-1 }
        if self.carField < 0 { self.carField = 0 }
        self.stopCar()
        
        //let nextX: CGFloat = CGFloat(self.carField) * COLUMN_WIDTH + COLUMN_WIDTH/2 - self.carView.frame.size.width/2
        UIView.animateWithDuration(NSTimeInterval(CAR_SWIPE_SPEED), delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
           self.updateHeroPosition()
        }, completion: nil)
    }
    func moveCarToX(x: CGFloat) {
        self.carView.center.x = x
    }
    
    func onTick() {
        if (carView.layer.presentationLayer() != nil && obstacleBehaviour.testHitRect(carView.layer.presentationLayer()!.frame)) {
            self.gameOver()
        } else {
            self.bonusManager.gameSpeed = self.obstacleBehaviour.getFallingSpeed()
            self.bonusManager.tick(self.carView)
            
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
    
    
    // Bonus manager delegate
    
    func energyPicked(bounsAmount: Int) {
        self.energyManager.appendEnergy(bounsAmount, startIfStopped: true)
    }
    
    //energy manager delegate
    
    func energyEmptied() {
        self.obstacleBehaviour.hide()
    }
    
    func energyIncreased() {
        self.obstacleBehaviour.show()
    }
    
    func gameOver() {
        tickTimer!.invalidate()
        tickTimer = nil
        self.moving = false
        self.movingDirection = 0
        
        self.bonusManager.stop()
        self.obstacleBehaviour.stop()
        self.energyManager.stop()

        self.stopAllAnimations()
        self.removeRecognizers()

        let tap = UITapGestureRecognizer(target :self, action:Selector("restartGame"));
        self.roadView.addGestureRecognizer(tap)
    }
    
    func stopAllAnimations() {
        self.stopCar()
    }
    
    func roadFieldWidth() -> CGFloat {
        return self.view.frame.size.width / CGFloat(FIELDS_NUM)
    }
    
    func updateHeroPosition() {
        self.carView.center.x = self.getHeroXByFieldIndex(self.carField)
    }
    
    func getHeroXByFieldIndex(fieldIndex: Int) -> CGFloat {
        return CGFloat(fieldIndex) * self.roadFieldWidth() + self.roadFieldWidth() / 2
    }

}


