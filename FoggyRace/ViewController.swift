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
    var fogView: FogView!
    
    

    var roadLinesView:  RoadLinesView!


    
    var carView: UIView!
    var carPosition: Int = 1
    let minCarPosition: Int = 0
    let maxCarPosition: Int = 2
    
    let COLUMN_WIDTH: CGFloat = 256
    let ROAD_LINE_NUMS = 3
    
    var tickTimer: NSTimer?
    
    
    lazy var backgroundMusic: AVAudioPlayer = {
        let url = NSBundle.mainBundle().URLForResource("backstage", withExtension: "mp3")
        let player = AVAudioPlayer(contentsOfURL: url, error: nil)
        player.numberOfLoops = -1
        return player
    }()


    
    func DEGREES_TO_RADIANS(x: Float) -> Float { return Float(M_PI) * x / 180.0 }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.startGame()
        backgroundMusic.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startGame() {
        self.runLines()

        self.createFog()
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
        
        self.fogView.run()
        self.obstacleBehaviour.run()
        self.addRecognizers()
        self.scheduleTickTimer()
        
        scoreLabel.text = "0"
    }
    
    func addRecognizers() {
        var swipeLeft = UISwipeGestureRecognizer(target :self, action:Selector("handleSwipe:"));
        var swipeRight = UISwipeGestureRecognizer(target :self, action:Selector("handleSwipe:"));
        
        // Setting the swipe direction.
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left;
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right;
        
        // Adding the swipe gesture on image view
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
        obstacleBehaviour = ObstacleBehaviour(roadView: self.roadView, linesNum: ROAD_LINE_NUMS)
        obstacleBehaviour.run()
    }
    
    
    
    
    func createFog() {
        fogView = FogView(animationMinX: 256, animationMaxX: 512)
        fogView.frame.size = CGSize(width: self.roadView.frame.size.width, height: self.roadView.frame.size.width)
        fogView.frame.origin = CGPoint(x: self.roadView.frame.size.width/2 - fogView.frame.size.width/2,
            y: self.roadView.frame.size.height/2 - fogView.frame.size.height/2)
        fogView.run()
        self.view.addSubview(fogView);
    }
    
    func runLines(){
        roadLinesView = RoadLinesView()
        roadLinesView.userInteractionEnabled = false

        roadLinesView.frame.size = CGSize(width: self.roadView.frame.size.width, height: self.roadView.frame.size.height)
        roadLinesView.frame.origin = CGPoint(x: 0,
            y: 0)
        roadLinesView.run()
        self.view.addSubview(roadLinesView);

    }
    
    func scheduleTickTimer() {
        tickTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("onTick"), userInfo: nil, repeats: true)
    }
    
    func drawCar() {
        var image = UIImage(named: "car.png")
        carView = UIImageView(image: image)
        carView.frame.origin.x = roadView.frame.size.width/2 - carView.frame.size.width/2
        carView.frame.origin.y = roadView.frame.height - carView.frame.size.height - 10
        
        roadView.addSubview(carView);
    }

    
    func handleSwipe(swipe: UISwipeGestureRecognizer) {

        
        if (swipe.direction == UISwipeGestureRecognizerDirection.Left) {
            if (carPosition == 1) {
                carPosition--
                self.moveCar(-1)
                UIView.animateWithDuration(0.2,
                    delay: 0.0,
                    options: nil,
                    animations: {
                         self.carView.transform = CGAffineTransformMakeRotation(CGFloat(self.DEGREES_TO_RADIANS(-30)))
                    },
                    completion: { finished in
                        UIView.animateWithDuration(0.2,
                            delay: 0.0,
                            options: nil,
                            animations: {
                                self.carView.transform = CGAffineTransformMakeRotation(CGFloat(self.DEGREES_TO_RADIANS(0)))
                            },
                            completion: nil
                        )
                    }
                )

             }
            else if (carPosition == maxCarPosition){
                carPosition--
                self.moveCar(-1)
                UIView.animateWithDuration(0.2,
                    delay: 0.0,
                    options: nil,
                    animations: {
                        self.carView.transform = CGAffineTransformMakeRotation(CGFloat(self.DEGREES_TO_RADIANS(-30)))
                    },
                    completion: { finished in
                        UIView.animateWithDuration(0.2,
                            delay: 0.0,
                            options: nil,
                            animations: {
                                self.carView.transform = CGAffineTransformMakeRotation(CGFloat(self.DEGREES_TO_RADIANS(0)))
                            },
                            completion: { finished in
                            }
                        )
                    }
                )

            }
        }

        if (swipe.direction == UISwipeGestureRecognizerDirection.Right) {
            if (carPosition == 1){
                carPosition++
                self.moveCar(1)
                UIView.animateWithDuration(0.2,
                    delay: 0.0,
                    options: nil,
                    animations: {
                        self.carView.transform = CGAffineTransformMakeRotation(CGFloat(self.DEGREES_TO_RADIANS(30)))
                    },
                    completion: { finished in
                        UIView.animateWithDuration(0.2,
                            delay: 0.0,
                            options: nil,
                            animations: {
                                self.carView.transform = CGAffineTransformMakeRotation(CGFloat(self.DEGREES_TO_RADIANS(0)))
                            },
                            completion: { finished in
                                
                            }
                        )
                    }
                )

            }
            else if (carPosition == minCarPosition){
                carPosition++
                self.moveCar(1)
                UIView.animateWithDuration(0.2,
                    delay: 0.0,
                    options: nil,
                    animations: {
                        self.carView.transform = CGAffineTransformMakeRotation(CGFloat(self.DEGREES_TO_RADIANS(30)))
                    },
                    completion: { finished in
                        UIView.animateWithDuration(0.2,
                            delay: 0.0,
                            options: nil,
                            animations: {
                                self.carView.transform = CGAffineTransformMakeRotation(CGFloat(self.DEGREES_TO_RADIANS(0)))
                            },
                            completion: { finished in
                            }
                        )
                    }
                )

            }
        }

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
        self.stopCar()
        let nextX: CGFloat = CGFloat(self.carPosition) * COLUMN_WIDTH + COLUMN_WIDTH/2 - self.carView.frame.size.width/2
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.carView.frame.origin.x = nextX
        }, completion: nil)
    }
    
    func onTick() {
        if (obstacleBehaviour.testHitRect(carView.layer.presentationLayer().frame)) {
            self.gameOver()
        } else {
            self.scoreLabel.text = String(self.obstacleBehaviour.fallsNum)
        }
    }
    
    func gameOver() {
        tickTimer!.invalidate()
        tickTimer = nil
        

        self.stopAllAnimations()
        self.removeRecognizers()

        var tap = UITapGestureRecognizer(target :self, action:Selector("restartGame"));
        self.roadView.addGestureRecognizer(tap)
    }
    
    func stopAllAnimations() {
        self.stopCar()
        self.obstacleBehaviour.stop()
        self.fogView.stop()
    }

}

