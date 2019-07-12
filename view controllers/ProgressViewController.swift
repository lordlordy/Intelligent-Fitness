//
//  ProgressViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 25/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit
import HealthKit

class ProgressViewController: UIViewController {
    
    enum GraphType: Int{
        case Tests = 0
        case Sets = 1
        case HR = 2
        case TSB = 3
        case Cals = 4
        case Ed = 5
    }

    private var calories: [(key: Date, value: Double)] = []
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var graphSegmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        graphView.setGraphs(graphs: createDummyData())
    }
    
    @IBAction func menuBarTapped(_ sender: UISegmentedControl) {
        if let type = GraphType(rawValue: graphSegmentedControl.selectedSegmentIndex){
            switch type{
            case .Cals:
                print("Cals")
                createCalorieGraph()
            case .Ed:
                print("Ed")
            case .Sets:
                print("Sets")
            case .HR:
                print("HR")
                // remove all graphs
                graphView.removeAllGraphs()
                // the following calls will add graphs
                createHRGraph()
                createHRVGraph()
            case .Tests:
                print("Tests")
            case .TSB:
                print("TSB")
                createExerciseTSBGraph()
            }
        }
    }
    
    @IBAction func showInfo(_ sender: Any) {
        let alert = UIAlertController(title: "Chart Explantion", message: "This is a message", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func createHRGraph(){
        //check healthkit access
        
        
        let ninetyDaysAgo: Date = Calendar.current.date(byAdding: DateComponents(day: -90), to: Date())!
        HealthKitAccess.shared.getRestingHRData(dateRange: (from: ninetyDaysAgo, to:Date())) { (data) in
            if data.count > 0{
                self.graphView.addGraph(graph: Graph(data: data, colour: .red))
            }
        }
    }
    
    private func createHRVGraph(){
        let ninetyDaysAgo: Date = Calendar.current.date(byAdding: DateComponents(day: -90), to: Date())!
        HealthKitAccess.shared.getHRVData(dateRange: (from: ninetyDaysAgo, to:Date())) { (data) in
            if data.count > 0{
                self.graphView.addGraph(graph: Graph(data: data, colour: .magenta))
            }
        }
    }
    
    private func createCalorieGraph(){
        HealthKitAccess.shared.getCalorieSummary(dateRange: nil) { (data) in
            if data.count == 0{
                self.requestPermissions()
            }else{
                let tsbData = self.createTSBData(from: data)
                // just show last 90 days of data
                let ninetyDaysAgo: Date = Calendar.current.date(byAdding: DateComponents(day: -90), to: Date())!
                let filteredData = tsbData.filter({$0.date >= ninetyDaysAgo})
                print(filteredData)
                let ctlGraph = Graph(data: filteredData.map({ (date: $0.date, value: $0.ctl) }), colour: .red)
                let atlGraph = Graph(data: filteredData.map({ (date: $0.date, value: $0.atl) }), colour: .green)
                let tsbGraph = Graph(data: filteredData.map({ (date: $0.date, value: $0.tsb) }), colour: .yellow)
                tsbGraph.fill = true
                self.graphView.setGraphs(graphs: [ctlGraph, atlGraph, tsbGraph])
            }
        }
        
    }

    private func createExerciseTSBGraph(){
        HealthKitAccess.shared.getExerciseTimeSummary(dateRange: nil) { (data) in
            if data.count == 0{
                self.requestPermissions()
            }else{
                //this data is in hours. For now assume a RPE of 5 using 7 as benchmark for threshol. ie hour at RPE 7 is TSS 100
                //This comes about as estimating TSS from time and rpe we have: TSS ~ (RPE * RPE) * hrs
                //We want RPE 7 to give 100. Thus we have:
                //TSS for 1 hour @ 7 = 100. Thus we want to find factor, f such (7*7)*1*f = 100 => f = 100/49
                //Thus is we're assuming RPE 5 then TSS = Hrs * 5 * 5 * f = hrs * 25 * 100 /49 = hrs * 2500 / 49
                let tssFactor: Double = 2500.0 / 49.0
                var tssData: [(date: Date, value: Double)] = []
                for d in data{
                    tssData.append((date:d.date, value: d.value * tssFactor))
                }
                let tsbData = self.createTSBData(from: tssData)
                // just show last 90 days of data
                let ninetyDaysAgo: Date = Calendar.current.date(byAdding: DateComponents(day: -90), to: Date())!
                let filteredData = tsbData.filter({$0.date >= ninetyDaysAgo})
                print(filteredData)
                let ctlGraph = Graph(data: filteredData.map({ (date: $0.date, value: $0.ctl) }), colour: .red)
                let atlGraph = Graph(data: filteredData.map({ (date: $0.date, value: $0.atl) }), colour: .green)
                let tsbGraph = Graph(data: filteredData.map({ (date: $0.date, value: $0.tsb) }), colour: .yellow)
                tsbGraph.fill = true
                self.graphView.setGraphs(graphs: [ctlGraph, atlGraph, tsbGraph])
            }
        }
    }

    private func createTSBData(from: [(date: Date, value: Double)]) -> [(date: Date, value: Double, ctl: Double, atl: Double, tsb: Double)]{
        // need to have an ordered series of dates without any gaps
        let orderedInput = from.sorted { $0.date < $1.date}
        var gaplessData: [(date: Date, value: Double)] = []
        var previousDate: Date? = nil
        var haveFirstNoneZero: Bool = false
        for d in orderedInput{
            haveFirstNoneZero = haveFirstNoneZero || (d.value > 0.001)
            if haveFirstNoneZero{
                if let pd = previousDate{
                    var nextDay = Calendar.current.date(byAdding: DateComponents(day:1), to: pd)!
                    while !Calendar.current.isDate(d.date, inSameDayAs: nextDay){
                        gaplessData.append((nextDay, 0.0))
                        nextDay = Calendar.current.date(byAdding: DateComponents(day:1), to: nextDay)!
                    }
                }
                gaplessData.append(d)
                previousDate = d.date
            }
        }
        var atl: Double = 0.0
        var ctl: Double = 0.0
        var result: [(date: Date, value: Double, ctl: Double, atl: Double, tsb: Double)] = []
        let ctlFactor: Double = exp(-1/42.0)
        let atlFactor: Double = exp(-1/7.0)
        for d in gaplessData{
            ctl = d.value * (1 - ctlFactor) + ctl * ctlFactor
            atl = d.value * (1 - atlFactor) + atl * atlFactor
            result.append((date: d.date , value: d.value, ctl: ctl, atl: atl, tsb: ctl-atl))
        }
        return result
    }
    
    private func createDummyData() -> [Graph]{
        var ctlData: [(Date, Double)] = []
        var atlData: [(Date, Double)] = []
        var tsbData: [(Date, Double)] = []
        var dayTss: Double = 50
        var dayCTL: Double = 25.0
        var dayATL: Double = 15.0
        let ctlFactor: Double = exp(-1/42.0)
        let atlFactor: Double = exp(-1/7.0)
        for i in 1...90{
            let random = Double.random(in: 0..<1)
            let factor = random * random
            dayTss = 110 * factor
            if Int.random(in: 1...10)<3{
                dayTss = 0.9
            }
            let d = Calendar.current.date(byAdding: DateComponents(day:i), to: Date())!
            dayCTL = dayTss * (1 - ctlFactor) + dayCTL * ctlFactor
            dayATL = dayTss * (1 - atlFactor) + dayATL * atlFactor
            ctlData.append((d, dayCTL))
            atlData.append((d, dayATL))
            tsbData.append((d, dayCTL - dayATL))
            
        }
        
        let tsbGraph = Graph(data: tsbData, colour: .yellow)
        tsbGraph.fill = true
        
        return [tsbGraph, Graph(data: ctlData, colour: .red), Graph(data: atlData, colour: .green)]
    }
    
    private func requestPermissions(){
        let alert = UIAlertController(title: "HealthKit Access", message: "This graph requires access to your health kit data", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Give Permission", style: .default, handler: { (action) in
            HealthKitAccess.shared.authorizeHealthKit(completion: { (success, error) in
                if let e = error{
                    print(e)
                }
                let title: String = success ? "Success" : "Failed"
                let msg: String = success ? "Thanks. Access given" : "Access failed"
                let alert = UIAlertController(title: title, message: msg, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            })
        }))
        self.present(alert, animated: true, completion: nil)
    }
    

}
