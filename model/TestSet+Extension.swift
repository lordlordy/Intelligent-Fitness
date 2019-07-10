//
//  TestSet+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 04/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension TestSet{
    
    func summaryString() -> String{
        let results: [String] = allTests().map({$0.resultString()})
        return results.joined(separator: "\n")
    }
    
    func numberOfTests() -> Int{
        return tests?.count ?? 0
    }
    
    func test(atOrder order: Int16) -> Test?{
        for t in tests!{
            if let test = t as? Test{
                if test.order == order{
                    return test
                }
            }
        }
        return nil
    }
    
    func allTests() -> [Test]{
        let results = tests?.allObjects as? [Test] ?? []
        return results.sorted(by: {$0.order < $1.order})
    }
}
