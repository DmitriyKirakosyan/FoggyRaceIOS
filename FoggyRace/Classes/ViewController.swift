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

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var roadView: UIView!
    var obstacleBehaviour: ObstacleBehaviour!
    var bonusManager: BonusManager!
    var energyManager: EnergyManager!

    var roadLinesView:  RoadLinesView!

    var moving: Bool = false
    var movingDirection: Int = 0
    var panStartPoint: CGFloat = 0
    
    var heroView: HeroView!
    var carField: Int = 3
    let minCarPosition: Int = 0
    let maxCarPosition: Int = 5
    
    let CAR_SWIPE_SPEED: CGFloat = 0.1
    
    let CAR_SPEED: CGFloat = 6
    
    let FIELDS_NUM:Int = 6
    
    var tickTimer: Timer?
    
    
    lazy var backgroundMusic: AVAudioPlayer = {
        let url = Bundle.main.url(forResource: "radio", withExtension: "mp3")
        let player = try? AVAudioPlayer(contentsOf: url!)
        player!.numberOfLoops = -1
        return player!
    }()


    
    func DEGREES_TO_RADIANS(_ x: Float) -> Float { return .pi * x / 180.0 }

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundMusic.play()
        
        self.bonusManager = BonusManager(stageView: self.view, fieldsNum: FIELDS_NUM)
        self.bonusManager.delegate = self
        self.energyManager = EnergyManager(stageView: self.view)
        self.energyManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        
        self.heroView.startAnimating()
    }
    
    @objc func restartGame() {
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
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleSwipe(_:)))
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleSwipe(_:)))

        swipeLeft.direction = UISwipeGestureRecognizerDirection.left;
        swipeRight.direction = UISwipeGestureRecognizerDirection.right;
        
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
    
    
    //MARK: - Obstacles
    func runObstacles() {
        obstacleBehaviour = ObstacleBehaviour(roadView: self.roadView, linesNum: FIELDS_NUM)
        obstacleBehaviour.run()
    }
    
    //MARK: - Road Lines
    func runLines(){
        roadLinesView = RoadLinesView(frame: CGRect(x: 0, y: 0, width: roadView.frame.size.width, height: roadView.frame.size.height), linesNum: FIELDS_NUM)
        roadLinesView.isUserInteractionEnabled = false

        self.roadView.addSubview(roadLinesView);
        roadLinesView.run()
    }
    
    func scheduleTickTimer() {
        tickTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ViewController.onTick), userInfo: nil, repeats: true)
    }
    
    func drawCar() {
        heroView = HeroView()
        let heroSize = roadView.frame.size.width / CGFloat(FIELDS_NUM)
        heroView.frame = CGRect(x: 0, y: 0, width: heroSize, height: heroSize)
        
//        heroView.backgroundColor = .red
        
        self.updateHeroPosition()
        
        heroView.frame.origin.y = roadView.frame.height - heroView.frame.size.height - 10
        
        roadView.addSubview(heroView);
    }

    
    @objc func handleSwipe(_ swipe: UISwipeGestureRecognizer) {
        let direction = swipe.direction == UISwipeGestureRecognizerDirection.left ? -1 : 1
        self.moveCar(direction)
        let rotationSpeed = TimeInterval(CAR_SWIPE_SPEED)
        UIView.animate(withDuration: rotationSpeed,
            delay: 0.0,
            options: [],
            animations: {
                self.heroView.transform = CGAffineTransform(rotationAngle: CGFloat(self.DEGREES_TO_RADIANS(Float(direction) * 30)))
            },
            completion: { finished in
                UIView.animate(withDuration: rotationSpeed,
                    delay: 0.0,
                    options: [],
                    animations: {
                        self.heroView.transform = CGAffineTransform(rotationAngle: CGFloat(self.DEGREES_TO_RADIANS(0)))
                    },
                    completion: nil
                )
            }
        )
    }
    
    func normalizeCarRotation()
    {
        self.heroView.transform = CGAffineTransform(rotationAngle: CGFloat(self.DEGREES_TO_RADIANS(0)))
    }
    
    func stopCar() {
        self.normalizeCarRotation()
        
        guard let layer = self.heroView.layer.presentation() else {
            return
        }
        
        self.heroView.layer.removeAllAnimations()
        self.heroView.frame.origin = layer.frame.origin
    }
    func moveCar(_ direction: Int) {
      //  self.carView.frame.origin.x += 5 * CGFloat(direction)
        self.carField += direction
        if self.carField > FIELDS_NUM-1 { self.carField = FIELDS_NUM-1 }
        if self.carField < 0 { self.carField = 0 }
        self.stopCar()
        
        //let nextX: CGFloat = CGFloat(self.carField) * COLUMN_WIDTH + COLUMN_WIDTH/2 - self.carView.frame.size.width/2
        UIView.animate(withDuration: TimeInterval(CAR_SWIPE_SPEED), delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
           self.updateHeroPosition()
        }, completion: nil)
    }
    func moveCarToX(_ x: CGFloat) {
        self.heroView.center.x = x
    }
    
    @objc func onTick() {
        if (heroView.layer.presentation() != nil && obstacleBehaviour.testHitRect(heroView.layer.presentation()!.frame)) {
            self.gameOver()
        } else {
            self.bonusManager.gameSpeed = self.obstacleBehaviour.getFallingSpeed()
            self.bonusManager.tick(self.heroView)
            
            self.scoreLabel.text = String(self.obstacleBehaviour.fallsNum)
            
            if (self.moving)
            {
                self.heroView.center.x += CGFloat(self.movingDirection) * CAR_SPEED
                if self.heroView.center.x < 50 { self.heroView.center.x = 50 }
                let rightEdge = self.view.frame.size.width - 50
                if self.heroView.center.x > rightEdge { self.heroView.center.x = rightEdge }
                
            }
        }
    }
    
    
    // Bonus manager delegate
    
    func energyPicked(_ bounsAmount: Int) {
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

        let tap = UITapGestureRecognizer(target :self, action:#selector(ViewController.restartGame));
        self.roadView.addGestureRecognizer(tap)
    }
    
    func stopAllAnimations() {
        self.stopCar()
        self.heroView.stopAnimating()
    }
    
    func roadFieldWidth() -> CGFloat {
        return self.roadView.frame.size.width / CGFloat(FIELDS_NUM)
    }
    
    func updateHeroPosition() {
        self.heroView.center.x = self.getHeroXByFieldIndex(self.carField)
    }
    
    func getHeroXByFieldIndex(_ fieldIndex: Int) -> CGFloat {
        return CGFloat(fieldIndex) * self.roadFieldWidth() + self.roadFieldWidth() / 2
    }

}


