//
//  BonusView.swift
//  FoggyRace
//
//  Created by Dmitriy Kirakosyan on 22/02/2015.
//  Copyright (c) 2015 Glowman. All rights reserved.
//

import UIKit

class BonusView: UIView {
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        let image = UIImage(named: "battery_bonus.png")
        let imageView = UIImageView(image: image)
        imageView.frame = self.frame
        self.addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
