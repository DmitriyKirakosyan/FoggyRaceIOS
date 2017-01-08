//
//  EnergyManager.swift
//  FoggyRace
//
//  Created by Dmitriy Kirakosyan on 22/02/2015.
//  Copyright (c) 2015 Glowman. All rights reserved.
//

import UIKit

protocol EnergyManagerDelegate {
    func energyEmptied()
    func energyIncreased()
}

class EnergyManager: NSObject {
    
    var stageView: UIView!
    var energyContainerView: UIImageView!
    var energyView: UIView!
    
    var currentEnergy = 0
    
    var maxEnergyViewWidth: CGFloat = 0

    let MAX_ENERGY = 25
    let REDUCE_SPEED = 1
    
    var reduceEnergyTimer: Timer?
    
    var delegate: EnergyManagerDelegate?
    
    
    init(stageView: UIView) {
        super.init()
        self.stageView = stageView
        self.createEnergyComponent()
    }
    
    func setFullEnergy() {
        let oldEnergy = self.currentEnergy
        self.currentEnergy = MAX_ENERGY
        self.updateEnergyView()
        if oldEnergy <= 0 {
            if let energyDelegate = self.delegate {
                energyDelegate.energyIncreased()
            }
        }
    }
    
    func appendEnergy(_ amount: Int, startIfStopped: Bool) {
        let oldEnergy = self.currentEnergy
        self.currentEnergy += amount
        if self.currentEnergy > MAX_ENERGY { self.currentEnergy = MAX_ENERGY }
        self.updateEnergyView()
        
        if oldEnergy <= 0 {
            if  startIfStopped {
                self.run()
            }
            if let energyDelegate = self.delegate {
                energyDelegate.energyIncreased()
            }
        }
    }
    
    func run() {
        self.reduceEnergyTimer = Timer.scheduledTimer(timeInterval: TimeInterval(REDUCE_SPEED), target: self, selector: #selector(EnergyManager.onTimer), userInfo: nil, repeats: true)
    }
    
    func stop() {
        if let timer = reduceEnergyTimer {
            timer.invalidate()
        }
        reduceEnergyTimer = nil
    }
    
    func createEnergyComponent() {
        let image = UIImage(named: "battery_empty")
        energyContainerView =  UIImageView(image: image)
        energyContainerView.frame.size = CGSize(width: energyContainerView.frame.size.width/4, height: energyContainerView.frame.size.height/4)
        
        energyContainerView.frame.origin = CGPoint(x: stageView.frame.width - energyContainerView.frame.size.width,
            y: 0)
        
        self.stageView.addSubview(energyContainerView)
        
        
        //energy
        self.maxEnergyViewWidth = energyContainerView.frame.size.width - 30
        let energyFrame = CGRect(x: 20, y: energyContainerView.frame.size.height/4, width: maxEnergyViewWidth, height: energyContainerView.frame.size.height / 2)
        self.energyView = UIView(frame: energyFrame)
        self.energyView.backgroundColor = UIColor.red

        self.energyContainerView.addSubview(self.energyView)
    }
    
    
    func updateEnergyView() {
        self.energyView.frame.size.width = maxEnergyViewWidth * (CGFloat(self.currentEnergy) / CGFloat(MAX_ENERGY))
    }
    
    
    func onTimer() {
        if (self.currentEnergy > 0) {
            self.currentEnergy -= 1
            self.updateEnergyView()
        } else {
            self.stop()
            if let energyDelegate = self.delegate {
                energyDelegate.energyEmptied()
            }
        }
    }
}
