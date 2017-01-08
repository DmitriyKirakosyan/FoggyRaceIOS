//
//  LineBehaviour.swift
//  FoggyRace
//
//  Created by Kuznetsov Mikhail on 01.01.15.
//  Copyright (c) 2015 Glowman. All rights reserved.
//

import UIKit
class RoadLinesView: UIView {
    var lines: [AnimatedLineView] = []
    var linesNum:Int = 0
    
    
    init(frame: CGRect, linesNum: Int) {
        super.init(frame: frame)
        self.linesNum = linesNum
        self.createLines()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func createLines() {
        for i in 0..<linesNum-1 {
            let gapSize:CGFloat = self.frame.size.width / CGFloat(linesNum)

            let line = AnimatedLineView(frame: CGRect(x: gapSize + CGFloat(i) * gapSize, y: 0, width: 4, height: self.frame.height))
            lines.append(line)
            self.addSubview(line)
        }
    }
    
    func stop() {
        for line in lines {
            line.layer.removeAllAnimations()
        }
    }
    
    func run() {
        for line in lines {
            line.animate()
        }
    }
    

}
