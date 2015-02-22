//
//  BonusManager.swift
//  FoggyRace
//
//  Created by Dmitriy Kirakosyan on 22/02/2015.
//  Copyright (c) 2015 Glowman. All rights reserved.
//

import UIKit

protocol BonusManagerDelegate {
    func energyPicked()
}

class BonusManager: NSObject {
    var delegate: BonusManagerDelegate?
    
    var stageView: UIView!
    var fieldsNum: Int = 0
    
    
    init(stageView: UIView, fieldsNum: Int) {
        super.init()
        self.stageView = stageView
        self.fieldsNum = fieldsNum
    }
}