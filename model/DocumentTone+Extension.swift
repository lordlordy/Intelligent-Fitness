//
//  DocumentTone+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 06/08/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

enum DocumentToneProperty: String{
    case tones
}

extension DocumentTone{
    
    var toneArray: [Tone]{
        return tones?.allObjects as? [Tone] ?? []
    }
    
    func getTone(forName name: String) -> Tone{
        for c in toneArray{
            if c.type == name{
                return c
            }
        }
        let t: Tone = CoreDataStackSingleton.shared.newTone()
        t.type = name
        mutableSetValue(forKey: DocumentToneProperty.tones.rawValue).add(t)
        CoreDataStackSingleton.shared.save()
        return t
    }
}


extension DocumentTone: InsightCategoryProtocol{
    func categoryName() -> String {
        return category ?? "not set"
    }
    
    func numberOfInsights() -> Int {
        return toneArray.count
    }
    
    func insightsArray() -> [InsightProtocol] {
        return toneArray
    }
    
    func insight(atIndex index: Int) -> InsightProtocol? {
        if index < toneArray.count{
            return toneArray[index]
        }
        return nil
    }
    
    func hasSubInsights() -> Bool {
        return false
    }
    
    
}
