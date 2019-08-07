//
//  InsightCategoryProtocol.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 07/08/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

protocol InsightCategoryProtocol {
    func categoryName() -> String
    func numberOfInsights() -> Int
    func insightsArray() -> [InsightProtocol]
    func insight(atIndex index: Int) -> InsightProtocol?
    func hasSubInsights() -> Bool
}
