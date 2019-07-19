//
//  Graph.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 19/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation
import UIKit

class Graph{
    var data: [(date: Date, value: Double)]
    var colour: UIColor
    var fill: Bool = false
    var invertFill: Bool = false
    var point: Bool = false
    var pointSize: CGFloat = 5.0
    
    var max: Double { return data.count>0 ? data.map({$0.value}).max()! : 0.0 }
    var min: Double { return data.count>0 ? data.map({$0.value}).min()! : 0.0 }
    var maxDate: Date { return data.count>0 ? data.map({$0.date}).max()! : Date()}
    var minDate: Date { return data.count>0 ? data.map({$0.date}).min()! : Date()}
    
    init(data: [(Date, Double)], colour: UIColor) {
        self.data = data
        self.colour = colour
    }
    
}

class LineGraph: Graph{
    
}

class PointGraph: Graph{
    
}
