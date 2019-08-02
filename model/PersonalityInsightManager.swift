//
//  PersonalityInsightManager.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 02/08/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

class PersonalityInsightManager{
    
    public static let shared: PersonalityInsightManager = PersonalityInsightManager()
    
    private let insightsURL: URL = URL(string: "https://lord-lordy2.eu-gb.mybluemix.net/twitter")!
    
    
    func saveInsights(){
        
    }
    
    func printInsightsToConsole(){
        var request = URLRequest(url: insightsURL)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let d = data{
                do{
                    let jsonDict = try JSONSerialization.jsonObject(with: d, options: .allowFragments) as! Dictionary<String, Any>
                    if let needs = jsonDict["needs"] as? NSArray{
                        print("NEEDS:")
                        for n in needs{
                            if let dict = n as? Dictionary<String, Any>{
                                if let name = dict["name"] as? String{
                                    if let p = dict["percentile"] as? Double{
                                        print("\t\(name): \(p)")
                                    }
                                }
                            }
                        }
                    }
                    
                    if let values = jsonDict["values"] as? NSArray{
                        print("VALUES:")
                        for v in values{
                            if let dict = v as? Dictionary<String, Any>{
                                if let name = dict["name"] as? String{
                                    if let p = dict["percentile"] as? Double{
                                        print("\t\(name): \(p)")
                                    }
                                }
                            }
                        }
                    }
                    
                    if let personality = jsonDict["personality"] as? NSArray{
                        print("PERSONALITY:")
                        for v in personality{
                            if let dict = v as? Dictionary<String, Any>{
                                if let name = dict["name"] as? String{
                                    if let p = dict["percentile"] as? Double{
                                        print("\t\(name): \(p)")
                                    }
                                }
                                if let children = dict["children"] as? NSArray{
                                    print("\tSUB-CATEGORIES:")
                                    for c in children{
                                        if let cDict = c as? Dictionary<String, Any>{
                                            if let name = cDict["name"] as? String{
                                                if let p = cDict["percentile"] as? Double{
                                                    print("\t\t\(name): \(p)")
                                                }
                                            }
                                        }
                                    }                                }
                            }
                        }
                    }
                    
                    //                    if let personality = jsonDict["personality"]{
                    //                        print(personality)
                    //                    }
                    
                }catch{
                    print(error)
                }
            }
        }
        task.resume()
    }
    
//    private func getInsightsJSON() -> Dictionary<String, Any>{
//        
//    }
    
    private init(){
        
    }
    
}
