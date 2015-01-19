//
//  InfluenceObstacleBehaviour.swift
//  FoggyRace
//
//  Created by Kuznetsov Mikhail on 09.01.15.
//  Copyright (c) 2015 Glowman. All rights reserved.
//

import UIKit

class InfluenceObstacleBehaviour {
    var obstacleBehaviour: ObstacleBehaviour!
    
    convenience init(obstacleBehaviour: ObstacleBehaviour) {
        self.init()
        self.obstacleBehaviour = obstacleBehaviour
    }
    
    func run(){
        var obstacle: UIView
        

        for obstacle in obstacleBehaviour.obstacles {
            /*let layer:CALayer = obstacle.layer.presentationLayer() as CALayer;
         
            var y = obstacle.frame.origin.y
            var x = obstacle.frame.origin.x
            obstacle.layer.removeAllAnimations()

            var obstacle1 = obstacleBehaviour.createObstacle()
            obstacleBehaviour.obstacles.append(obstacle1)
            
            
            obstacle1.frame.origin.y = y - 50
            obstacle1.frame.origin.x = x
            obstacleBehaviour.roadView.addSubview(obstacle1)
            
            UIView.animateWithDuration(obstacleBehaviour.getFallingInterval(), delay: 0, options: UIViewAnimationOptions.CurveLinear,
                animations: {
                    obstacle1.frame.origin.y = self.obstacleBehaviour.roadView.frame.height
                }, completion: { Finished in
                   
                    self.obstacleBehaviour.removeObstacle(obstacle1)
                  
                    
                }
            )


           */
            obstacleBehaviour.pauseObstacle(obstacle)
            obstacleBehaviour.resumeObstacle(obstacle)
           // obstacle.frame.origin.y = obstacle.frame.origin.y - 50
       
            
            
          //  UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear,
           //     animations: {
           //         obstacle.frame.origin.y = obstacle.frame.origin.y - 50
            //    }, completion: { nil
         //   
        }
        
     }
}