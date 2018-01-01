//
//  BonusManager.swift
//  FoggyRace
//
//  Created by Dmitriy Kirakosyan on 22/02/2015.
//  Copyright (c) 2015 Glowman. All rights reserved.
//

import UIKit

protocol BonusManagerDelegate {
    func energyPicked(_ bounsAmount: Int)
}

class BonusManager: NSObject {
    var delegate: BonusManagerDelegate?
    
    var stageView: UIView!
    var fieldsNum: Int = 0
    
    var bonusReadyTimer: Timer?
    
    var gameSpeed: CGFloat = 0
    
    var bonuses: [BonusView] = []
    
    let BONUS_ENERGY_AMOUNT = 10
    
    
    init(stageView: UIView, fieldsNum: Int) {
        super.init()
        self.stageView = stageView
        self.fieldsNum = fieldsNum
    }
    
    func tick(_ heroView: UIView) {
        var result: BonusView? = nil
        for bonus in bonuses {
            if (bonus.layer.presentation() != nil &&
                bonus.layer.presentation()!.frame.intersects(heroView.frame)) {
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
        self.bonusReadyTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(BonusManager.onBonusReadyTimer), userInfo: nil, repeats: true)
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
        let bonus = BonusView(frame: getBonusFrame())
        bonuses.append(bonus)
        
        let line: Int = Int(arc4random() % UInt32(self.fieldsNum))
        bonus.frame.origin.y = -bonus.frame.size.height
        
        bonus.center.x = CGFloat(line) * self.getFieldWidth() + self.getFieldWidth()/2
        
        self.stageView.addSubview(bonus)
        
        UIView.animate(withDuration: TimeInterval(self.gameSpeed), delay: 0, options: UIViewAnimationOptions.curveLinear,
            animations: {
                bonus.frame.origin.y = self.stageView.frame.size.height
            }, completion: { finished in
                self.removeBonus(bonus)
            }
        )
    }
    
    func getBonusFrame() -> CGRect {
        let obstacleWidth = getFieldWidth()
        
        return CGRect(x: 0, y: 0, width: obstacleWidth, height: obstacleWidth)
    }

    
    func removeBonus(_ bonus: BonusView) {
        bonus.removeFromSuperview()
        if self.bonuses.index(of: bonus) != nil {
            self.bonuses.remove(at: self.bonuses.index(of: bonus)!)
        }
    }

    
    @objc func onBonusReadyTimer() {
        self.shootBonus()
    }
    
    func getFieldWidth() -> CGFloat {
        return stageView.frame.size.width/CGFloat(fieldsNum)
    }
}
