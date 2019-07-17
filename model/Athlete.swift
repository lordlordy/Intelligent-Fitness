//
//  AthleteProtocol.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 17/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

// Setting this up to make future move to athletes on a central DB easier. At the moment each insstance of this app only has one athlete
protocol Athlete {
    func getWorkouts() -> [Workout]
    
}
