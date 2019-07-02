//
//  Exercise+Extension.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 02/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

extension Exercise{
    
    func exerciseComplete() -> Bool{
        return actualReps >= plannedReps
    }
}
