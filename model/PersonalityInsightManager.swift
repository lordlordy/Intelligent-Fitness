//
//  PersonalityInsightManager.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 02/08/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

enum InsightType: String{
    case needs, values, personality
}

class PersonalityInsightManager{
    
    public static let shared: PersonalityInsightManager = PersonalityInsightManager()
    
    private let insightsURL: URL = URL(string: "https://lord-lordy2.eu-gb.mybluemix.net/twitter")!
    
    
    func saveInsights(completion: @escaping ([PersonalityInsight]) -> Swift.Void){
        readAndUpdateInsights(completion: completion)
    }
    
    func printInsightsToConsole(){
        for pi in CoreDataStackSingleton.shared.getPersonalityInsights(){
            pi.printSummary()
        }
    }
    
    private func readAndUpdateInsights(completion: @escaping ([PersonalityInsight]) -> Swift.Void){
        var request = URLRequest(url: insightsURL)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let d = data{
                var result: [PersonalityInsight] = []
                do{
                    let jsonDict = try JSONSerialization.jsonObject(with: d, options: .allowFragments) as! Dictionary<String, Any>
                    if let needs = jsonDict[InsightType.needs.rawValue] as? NSArray{
                        let pi: PersonalityInsight = CoreDataStackSingleton.shared.getPersonalityInsight(forType: .needs)
                        result.append(pi)
                        for n in needs{
                            if let dict = n as? Dictionary<String, Any>{
                                if let name = dict["name"] as? String{
                                    if let p = dict["percentile"] as? Double{
                                        pi.getInsight(forType: name).setReading(toValue: p, forDate: Date())
                                    }
                                }
                            }
                        }
                    }
                    
                    if let values = jsonDict[InsightType.values.rawValue] as? NSArray{
                        let pi: PersonalityInsight = CoreDataStackSingleton.shared.getPersonalityInsight(forType: .values)
                        result.append(pi)
                        for v in values{
                            if let dict = v as? Dictionary<String, Any>{
                                if let name = dict["name"] as? String{
                                    if let p = dict["percentile"] as? Double{
                                        pi.getInsight(forType: name).setReading(toValue: p, forDate: Date())
                                    }
                                }
                            }
                        }
                    }
                    
                    if let personality = jsonDict[InsightType.personality.rawValue] as? NSArray{
                        let pi: PersonalityInsight = CoreDataStackSingleton.shared.getPersonalityInsight(forType: .personality)
                        result.append(pi)
                        for v in personality{
                            if let dict = v as? Dictionary<String, Any>{
                                if let name = dict["name"] as? String{
                                    print(name)
                                    if let p = dict["percentile"] as? Double{
                                        pi.getInsight(forType: name).setReading(toValue: p, forDate: Date())
                                    }
                                    if let children = dict["children"] as? NSArray{
                                        for c in children{
                                            if let cDict = c as? Dictionary<String, Any>{
                                                if let n = cDict["name"] as? String{
                                                    print("Sub: \(n)")
                                                    if let p = cDict["percentile"] as? Double{
                                                        pi.getInsight(forType: name).getSubCategory(forType: n).setReading(toValue: p, forDate: Date())
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    completion(result)
                    
                }catch{
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    private init(){
        
    }
    
}
