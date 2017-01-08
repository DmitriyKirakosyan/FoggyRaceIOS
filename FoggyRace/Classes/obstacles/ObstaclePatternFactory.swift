//
//  ObstaclePatternFactory.swift
//  FoggyRace
//
//  Created by Dmitriy on 11/19/15.
//  Copyright © 2015 Glowman. All rights reserved.
//

import Foundation

class ObstaclePatternFactory: NSObject {
    
    let JSON_FILE_NAME = "road_patterns"
    
    fileprivate var _patternsData : Array<RoadPattern>?;
    
    override init() {
        super.init()
        
        if let path = Bundle.main.path(forResource: JSON_FILE_NAME, ofType: "json")
        {
            do
            {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions.mappedIfSafe)
                if let jsonResult: NSArray = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray
                {
                    _patternsData = []
                    for patternObject in jsonResult {
                        let pattern = RoadPattern(data: patternObject as! NSDictionary)
                        _patternsData!.append(pattern)
                    }
                }
            }
            catch
            {
                NSLog("ERROR! parcing json file : %@", JSON_FILE_NAME)
            }
        }
    }
    
    func  getRandomPattern() -> RoadPattern? {
        if let patterns = _patternsData {
           
            let index = arc4random() % UInt32(patterns.count)
            
            return patterns[Int(index)];
        }
        return nil;
    }
}
