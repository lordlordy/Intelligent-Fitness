//
//  ProgressViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 25/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit
import HealthKit

enum GraphType: Int{
    case Tests = 0
    case Sets = 1
    case HR = 2
    case TSB = 3
    case Cals = 4
    case Ed = 5

    func name() -> String{
        switch self{
        case .Tests: return "Test Graphs"
        case .Sets: return "Workout Graphs"
        case .HR: return "Heart Rate Graphs"
        case .TSB: return "Training Stress Balance Graphs"
        case .Cals: return "Calorie Graphs"
        case .Ed: return "Eddington Numbers"
        }
    }
    
    func explanation() -> String{
        switch self{
        case .Tests:
            return "Shows progress in your Functional Fitness Tests. The 'Choose' button allows you to switch between the different tests"
        case .Sets:
            return "Shows progress in your workouts. The 'Choose' button allows you to switch between the different tests"
        case .HR:
            return "Shows your heart data as recorded in the Health App. This graphs shows your resting hears and you heart rate variability"
        case .TSB:
            return "Training Stress Balance graph. This models your fitness, fatigue and form. This currently uses your activity time from the health app. It assumes an RPE of 5 on average which gives a TSS of ~55 per hour"
        case .Cals:
            return "A training stress balance graph based on calories as a good proxie for training stress. It models fitness, fatigue and form using a Banister Training Impulse Model"
        case .Ed:
            return "A graph of your Eddington numbers. This is a good single number measure of your progress. It gives the maximum KG such that you've lifted that amount on at least that many days. For more info look at http://www.eddingtonnumbers.me.uk"
        }
    }

}

class ProgressViewController: UIViewController {
    


    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var graphSegmentedControl: UISegmentedControl!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var toolBar = UIToolbar()
    private var picker = UIPickerView()
    private var selectedGraph: GraphType = .Tests
    private var selectedExercise: Int = 0
    private var selectedMeasure: Int = 0
    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        print(sender)
        print(sender.currentPage)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        graphView.setGraphs(graphs: createDummyData())
        graphSegmentedControl.selectedSegmentIndex = 0
        picker.backgroundColor = MAIN_BLUE
        picker.dataSource = self
        picker.delegate = self
        picker.setValue(UIColor.white, forKey: "textColor")
        picker.contentMode = .center
        picker.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        toolBar.backgroundColor = MAIN_BLUE
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        updateGraph(forExercise: ExerciseType(rawValue: Int16(selectedExercise)) ?? ExerciseType.pushUp, andMeasure: ExerciseMeasure(rawValue: selectedMeasure) ?? ExerciseMeasure.avReps)
    }
    
    @IBAction func chooseTapped(_ sender: Any) {
        self.view.addSubview(picker)
        self.view.addSubview(toolBar)
    }
    
    @objc func onDoneButtonTapped(){
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
    }
    
    
    @IBAction func menuBarTapped(_ sender: UISegmentedControl) {
        if let type = GraphType(rawValue: graphSegmentedControl.selectedSegmentIndex){
            selectedGraph = type
            switch type{
            case .Cals:
                createCalorieGraph()
            case .Ed:
                chooseButton.isEnabled = true
                chooseButton.isHidden = false
                titleLabel.text = "Eddington Numbers"
                print("Ed")
            case .Sets:
                createSetsGraph()
            case .HR:
                createHRGraph()
            case .Tests:
                createTestsGraph()
            case .TSB:
                createExerciseTSBGraph()
            }
        }
    }
    
    @IBAction func showInfo(_ sender: Any) {
        let alert = UIAlertController(title: "\(selectedGraph.name()) Explanation", message: selectedGraph.explanation(), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func createTestsGraph(){
        chooseButton.isEnabled = true
        chooseButton.isHidden = false
        titleLabel.text = "Functional Fitness Test"
        graphView.removeAllGraphs()
        let graph: Graph = Graph(data: WorkoutManager.shared.getExercises(forType: .sittingRisingTest).map({($0.date!, $0.valueFor(exerciseMeasure: .avReps))}), colour: .red)
        graphView.addGraph(graph: graph)
    }
    

    private func createSetsGraph(){
        chooseButton.isEnabled = true
        chooseButton.isHidden = false
        titleLabel.text = "Bench Press"
        graphView.removeAllGraphs()
        let bpData = WorkoutManager.shared.getExercises(forType: .benchPress).map({(date: $0.date!, value: $0.valueFor(exerciseMeasure: .maxKG))})
        for d in bpData{
            print(d.1)
        }
        let graph: Graph = Graph(data: bpData.sorted(by: {$0.date < $1.date}), colour: .red)
        graphView.addGraph(graph: graph)
    }

    private func createHRGraph(){
        chooseButton.isEnabled = false
        chooseButton.isHidden = true
        titleLabel.text = "Heart Rate Variability"
        // remove all graphs
        graphView.removeAllGraphs()
        // the following calls will add graphs
        
        let ninetyDaysAgo: Date = Calendar.current.date(byAdding: DateComponents(day: -90), to: Date())!
        HealthKitAccess.shared.getRestingHRData(dateRange: (from: ninetyDaysAgo, to:Date())) { (data) in
            if data.count > 0{
                self.graphView.addGraph(graph: Graph(data: data, colour: .red))
            }else{
                return
            }
        }
        HealthKitAccess.shared.getHRVData(dateRange: (from: ninetyDaysAgo, to:Date())) { (data) in
            if data.count == 0{
                self.requestPermissions()
            }else{
                self.graphView.addGraph(graph: Graph(data: data, colour: .magenta))
            }
        }
    }
    
    
    private func createCalorieGraph(){
        chooseButton.isEnabled = false
        chooseButton.isHidden = true
        titleLabel.text = "Calorie Based TSB"
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
        chooseButton.isEnabled = false
        chooseButton.isHidden = true
        titleLabel.text = "Training Stress Balance"
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
    
    private func updateGraph(forExercise exercise: ExerciseType, andMeasure measure: ExerciseMeasure){
        print("Updating graph for \(exercise) and \(measure)")
        titleLabel.text = "\(ExerciseDefinitionManager.shared.exerciseDefinition(for: exercise).name) - \(measure.string())"
        graphView.removeAllGraphs()
        let graph: Graph = Graph(data: WorkoutManager.shared.getExercises(forType: exercise).map({($0.date!, $0.valueFor(exerciseMeasure: measure))}).sorted(by: {$0.0 < $1.0}), colour: .red)
        graphView.addGraph(graph: graph)
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

extension ProgressViewController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch selectedGraph{
        case .Cals, .HR, .TSB: return 0
        case .Sets:
            if component == 0{
                return WorkoutManager.shared.exerciseTypes.count
            }else{
                return ExerciseMeasure.allCases.count
            }
        case .Tests:
            if component == 0{
                return WorkoutManager.shared.fftTypes.count
            }else{
                return ExerciseMeasure.allCases.count
            }
        case .Ed:
            return 0
        }
    }
    
}

extension ProgressViewController: UIPickerViewDelegate{
    

    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            if let def = getSelectedExerciseDefinition(forRow: row){
                return def.name
            }
        }else{
            return ExerciseMeasure(rawValue: row)?.string()
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Selected: \(row) in component: \(component)")
        if component == 0{
            selectedExercise = row
        }else{
            selectedMeasure = row
        }
        if let exercise = ExerciseType(rawValue: Int16(selectedExercise)){
            if let measure = ExerciseMeasure(rawValue: selectedMeasure){
                updateGraph(forExercise: exercise, andMeasure: measure)
            }
        }
    }
    
    
    private func getSelectedExerciseDefinition(forRow row: Int) -> ExerciseDefinition?{
        switch selectedGraph{
        case .Cals, .HR, .TSB, .Ed:
            return nil
        case .Sets:
            return ExerciseDefinitionManager.shared.exerciseDefinition(for: WorkoutManager.shared.exerciseTypes[row])
        case .Tests:
            return ExerciseDefinitionManager.shared.exerciseDefinition(for: WorkoutManager.shared.fftTypes[row])
        }
    }
    
}
