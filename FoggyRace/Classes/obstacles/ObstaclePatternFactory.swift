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
    
    private var _patternsData : Array<RoadPattern>?;
    
    override init() {
        super.init()
        
        if let path = NSBundle.mainBundle().pathForResource(JSON_FILE_NAME, ofType: "json")
        {
            do
            {
                let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                if let jsonResult: NSArray = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? NSArray
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
            return patterns[random() % patterns.count];
        }
        return nil;
    }
}