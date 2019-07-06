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
        return "THis is a test summary"
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
}
