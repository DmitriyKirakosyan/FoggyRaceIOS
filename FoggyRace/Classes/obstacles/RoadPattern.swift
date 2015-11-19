//
//  RoadPattern.swift
//  FoggyRace
//
//  Created by Dmitriy on 11/19/15.
//  Copyright © 2015 Glowman. All rights reserved.
//

import Foundation

class RoadPattern: NSObject {
    private var _data: NSDictionary;
    private var _obstacleData: NSDictionary;
    
    init(data: NSDictionary)
    {
        _data = data;
        _obstacleData = _data["obstacles"] as! NSDictionary;
    }
    
    func containsLine(lineIndex: Int) -> Bool {
        return lineIndex < _obstacleData.count;
    }
    
    func getObstaclePositionsForLine(lineIndex: Int) -> Array<Int> {
        return _obstacleData[String(lineIndex)] as! Array<Int>
    }
}