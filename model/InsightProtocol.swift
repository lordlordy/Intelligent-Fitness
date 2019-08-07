//
//  InsightProtocol.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 07/08/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

protocol InsightProtocol {
    func name() -> String
    func numberOfReadings() -> Int
    func mostRecentReading() -> (date: Date, value: Double)
    func insightReadings() -> [(date: Date, value: Double)]
    func subInsightsArray() -> [InsightProtocol]
    func subInsight(atIndex index: Int) -> InsightProtocol?
    func removeReading(forDate date: Date)
    func setInsightReading(forDate date: Date, toValue value: Double)
}
