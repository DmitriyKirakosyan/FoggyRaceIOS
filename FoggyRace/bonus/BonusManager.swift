//
//  BonusManager.swift
//  FoggyRace
//
//  Created by Dmitriy Kirakosyan on 22/02/2015.
//  Copyright (c) 2015 Glowman. All rights reserved.
//

import UIKit

protocol BonusManagerDelegate {
    func energyPicked(bounsAmount: Int)
}

class BonusManager: NSObject {
    var delegate: BonusManagerDelegate?
    
    var stageView: UIView!
    var fieldsNum: Int = 0
    
    var bonusReadyTimer: NSTimer?
    
    var gameSpeed: CGFloat = 0
    
    var bonuses: [BonusView] = []
    
    let BONUS_ENERGY_AMOUNT = 10
    
    
    init(stageView: UIView, fieldsNum: Int) {
        super.init()
        self.stageView = stageView
        self.fieldsNum = fieldsNum
    }
    
    func setGameSpeed(speed: CGFloat) {
        self.gameSpeed = speed
    }
    
    func tick(heroView: UIView) {
        var result: BonusView? = nil
        for bonus in bonuses {
            if (bonus.layer.presentationLayer() != nil &&
                bonus.layer.presentationLayer().frame.intersects(heroView.frame)) {
                    result = bonus
                    break
            }
        }
        
        if let foundBonus = result {
            foundBonus.layer.removeAllAnimations()
            if let existingDelegate = self.delegate {
                existingDelegate.energyPicked(BONUS_ENERGY_AMOUNT)
            }
        }

    }
    
    func run() {
        if self.bonusReadyTimer != nil { return }
        self.bonusReadyTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("onBonusReadyTimer"), userInfo: nil, repeats: true)
    }
    
    func stop() {
        if let readyTimer = self.bonusReadyTimer {
            readyTimer.invalidate()
        }
        self.bonusReadyTimer = nil
        
        for bonus in bonuses {
            bonus.layer.removeAllAnimations()
        }
        bonuses = []
    }
    
    
    //private
    
    func shootBonus(){
        var bonus = BonusView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        bonuses.append(bonus)
        
        
        let line: Int = random() % (self.fieldsNum)
        bonus.frame.origin.y = -bonus.frame.size.height
        
        bonus.center.x = CGFloat(line) * self.getFieldWidth() + self.getFieldWidth()/2
        
        self.stageView.addSubview(bonus)
        
        UIView.animateWithDuration(NSTimeInterval(self.gameSpeed), delay: 0, options: UIViewAnimationOptions.CurveLinear,
            animations: {
                bonus.frame.origin.y = self.stageView.frame.size.height
            }, completion: { finished in
                self.removeBonus(bonus)
            }
        )
    }
    
    func removeBonus(bonus: BonusView) {
        bonus.removeFromSuperview()
        if find(self.bonuses, bonus) != nil {
            self.bonuses.removeAtIndex(find(self.bonuses, bonus)!)
        }
    }

    
    func onBonusReadyTimer() {
        self.shootBonus()
    }
    
    func getFieldWidth() -> CGFloat {
        return stageView.frame.size.width/CGFloat(fieldsNum)
    }
}