//
//  ProgressViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 25/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit
import HealthKit

// TO DO - calculation of TSB should be moved from here

enum GraphType: Int{
    case Sets = 0
    case HR = 1
    case TSB = 2
    case Consistency = 3
    case Ed = 4
    case PowerUp = 5
    
    func name() -> String{
        switch self{
        case .Sets: return "Workout Graphs"
        case .HR: return "Heart Rate Graphs"
        case .TSB: return "Training Stress Balance Graphs"
        case .Consistency: return "Weekly Consistency"
        case .Ed: return "Eddington Numbers"
        case .PowerUp: return "PowerUps"
        }
    }
    
    func explanation() -> String{
        switch self{
        case .Sets:
            return "Shows progress in your workouts. The 'Choose' button allows you to switch between the different workouts and measures"
        case .HR:
            return "Shows your heart data as recorded in the Health App. This graphs shows your resting hears and you heart rate variability"
        case .TSB:
            return "Training Stress Balance graph. This models your fitness, fatigue and form. This currently uses your activity time from the health app. It assumes an RPE of 5 on average which gives a TSS of ~55 per hour. Can also see a similar graph using active calories as a proxie for TSS"
        case .Consistency:
            return "Show a measure of how many weeks you've done on the trot with 3 sessions per week and no more than 2 rest days between each. If you have a week that does not meet this criteria the current streak number is halved"
        case .Ed:
            return "A graph of your Eddington numbers. This is a good single number measure of your progress. It gives the maximum KG such that you've lifted that amount on at least that many days. For more info look at http://www.eddingtonnumbers.me.uk"
        case .PowerUp:
            return "This graph shows the progression of your power ups for attack and defence. Defence power-ups are given for consistency. Defence power-ups are currently being given for progression in your Max Rep X KG Eddington Number"
        }
    }

}

class ProgressViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var graphSegmentedControl: UISegmentedControl!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var toolBar = UIToolbar()
    private var picker = UIPickerView()
    private var selectedGraph: GraphType = .Sets
    private var selectedExercise: ExerciseType = ExerciseType.gobletSquat
    private var selectedMeasure: ExerciseMeasure = .totalKG
    private var validMeasures: [ExerciseMeasure]{ return ExerciseDefinitionManager.shared.exerciseDefinition(for: selectedExercise).setType.validMeasures() }
    private var selectedTSB: Int = 0
    private var isLTDEd: Bool = true
    
    private var graphView: GraphView!
    private var tableView: UITableView!
    
    private var graphData: [(title: String, data: [(date: Date, value: Double)])] = []
    private var collapsed: [Bool] = []
    private let CELL_ID = "DefaultCell"
    private var df: DateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        df.dateFormat = "dd-MMM-YY"

        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 2.0, height: scrollView.frame.size.height)
        scrollView.delegate = self
        
        graphView = GraphView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: scrollView.frame.size.height))
        print(graphView.frame)
        print(UIScreen.main.bounds)
        graphView.translatesAutoresizingMaskIntoConstraints = false
        graphView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.addSubview(graphView)
        
        tableView = UITableView(frame: CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.addSubview(tableView)
        
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
        
        updateGraph(forExercise: selectedExercise, andMeasure: selectedMeasure )

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CELL_ID)
        tableView.register(DataHeader.self, forHeaderFooterViewReuseIdentifier: DataHeader.reuseIdentifier)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecogniser:)))
        graphView.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 2.0, height: scrollView.frame.size.height)
        tableView.frame = CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        tableView.contentSize = CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        graphView.frame.size = CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height)
    }
    
    @objc func viewTapped(gestureRecogniser: UITapGestureRecognizer){
        switch selectedGraph{
        case .Sets, .TSB, .Ed:
            self.view.addSubview(picker)
            self.view.addSubview(toolBar)
        default:
            // do nothing
            return
        }
    }
    
    @objc func onDoneButtonTapped(){
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
    }
    
    
    @IBAction func menuBarTapped(_ sender: UISegmentedControl) {
        if let type = GraphType(rawValue: graphSegmentedControl.selectedSegmentIndex){
            selectedGraph = type
            switch type{
            case .Consistency: createConsistencyGraph()
            case .Ed: createEdGraph()
            case .Sets: createSetsGraph()
            case .HR: createHRGraph()
            case .TSB: createTSBGraph()
            case .PowerUp: createPowerUpGraph()
            }
        }
        picker.reloadAllComponents()
        picker.setNeedsDisplay()
    }
    
    @IBAction func showInfo(_ sender: Any) {
        let alert = UIAlertController(title: "\(selectedGraph.name()) Explanation", message: selectedGraph.explanation(), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func toggle(section: Int){
        if section < collapsed.count{
            collapsed[section] = !collapsed[section]
            tableView.reloadData()
        }
    }
    
    private func createPowerUpGraph(){
        let title: String  = "Power-Ups"
        titleLabel.text = title
        let pUps: [PowerUp] = CoreDataStackSingleton.shared.getPowerUps()
        let defence: [(Date, Double)] = pUps.map({($0.date!, Double($0.defense))})
        let attack: [(Date, Double)] = pUps.map({($0.date!, Double($0.attack))})
        graphData = [("Defence", defence), ("Attack", attack)]
        collapsed = [true, false]
        graphView.removeAllGraphs()
        let defenceLine: Graph = LineGraph(data: defence, colour: .red, title: "Defence")
        let defencePoints: PointGraph = PointGraph(data: defence, colour: .green, title: "")
        defencePoints.fill = true
        defencePoints.pointSize = 10.0
        let attackLine: Graph = LineGraph(data: attack, colour: .blue, title: "Attack")
        let attackPoints: PointGraph  = PointGraph(data: attack, colour: .cyan, title: "")
        attackPoints.fill = true
        attackPoints.pointSize = 10.0
        graphView.setGraphs(graphs: [defencePoints, defenceLine, attackPoints, attackLine])
    }
    
    private func createConsistencyGraph(){
        let title: String = "Consistency Streak"
        titleLabel.text = title
        let data: [(Date, Double)] = WorkoutManager.shared.getWeeks().sorted(by: {$0.startOfWeek < $1.startOfWeek}).map({($0.startOfWeek, Double($0.recursivelyCalculateConsistencyStreak()))})
        var maxValues: [(Date, Double)] = []
        var previousVal: Double = 0.0
        for d in data{
            let value: Double = max(previousVal, d.1)
            maxValues.append((d.0, value))
            previousVal = value
        }
        graphData = [(title, data), ("Max streak", maxValues)]
        collapsed = [false, false]
        graphView.removeAllGraphs()
        let graph: Graph = LineGraph(data: data, colour: .yellow, title: "Consistency")
        graph.fill = true
        graph.invertFill = true
        graphView.setGraphs(graphs: [graph, LineGraph(data: maxValues, colour: .red, title: "Max")])
    }
    
    private func createEdGraph(){
        let data: [(Date, Double)] = WorkoutManager.shared.timeSeries(forExeciseType: selectedExercise, andMeasure: selectedMeasure)
        let eddNum: EddingtonCalculator.EddingtonHistory = EddingtonCalculator().eddingtonHistory(timeSeries: data)

        var history = eddNum.annualHistory
        var preStr = "Annual"
        
        if isLTDEd{
            history = eddNum.ltdHistory
            preStr = "LTD"
        }
        
        titleLabel.text = "\(preStr) \(ExerciseDefinitionManager.shared.exerciseDefinition(for: selectedExercise).name) \(selectedMeasure.string()) Edd#"

        let edData: [(Date, Double)] = history.map({($0.date, Double($0.edNum))})
        let edContributors: [(Date, Double)] = history.map({($0.date, $0.contributor)})
        let edPlusOne: [(Date, Double)] = history.map({($0.date, Double($0.edNum + $0.plusOne))})
        let edGraph: Graph = LineGraph(data: edData, colour: .red, title: "Eddington Number")
        let contribGraph: PointGraph = PointGraph(data: edContributors, colour: .cyan, title: "Contributor")
        let plusOneGraph: Graph = LineGraph(data: edPlusOne, colour: .green, title: "Plus One")
        edGraph.fill = true
        edGraph.invertFill = true
        contribGraph.fill = true
        graphData = [("Ed Num", edData), ("Contributors", edContributors), ("Plus One", history.map({($0.date, Double($0.plusOne))}))]
        collapsed = [true, true, false]
        graphView.removeAllGraphs()
        graphView.setGraphs(graphs: [edGraph, contribGraph, plusOneGraph])
        
    }

    private func createSetsGraph(){
        updateGraph(forExercise: selectedExercise, andMeasure: selectedMeasure)
    }

    private func createHRGraph(){
        let title: String = "Heart Rate Variability"
        titleLabel.text = title
        // remove all graphs
        graphView.removeAllGraphs()
        graphData = []
        collapsed = []
        // the following calls will add graphs
        
        let ninetyDaysAgo: Date = Calendar.current.date(byAdding: DateComponents(day: -90), to: Date())!
        HealthKitAccess.shared.getRestingHRData(dateRange: (from: ninetyDaysAgo, to:Date())) { (data) in
            if data.count > 0{
                self.graphData.append(("Heart Rate", data))
                self.collapsed.append(false)
                self.graphView.addGraph(graph: LineGraph(data: data, colour: .red, title: "Heart Rate"))
            }else{
                return
            }
        }
        HealthKitAccess.shared.getHRVData(dateRange: (from: ninetyDaysAgo, to:Date())) { (data) in
            if data.count == 0{
                DispatchQueue.main.async {
                    self.requestPermissions()
                    self.titleLabel.text = "Dummy Data"
                }
                self.graphView.removeAllGraphs()
                self.graphView.setGraphs(graphs: [])
                self.graphData = [("CTL", self.graphView.dummyCTLData), ("ATL", self.graphView.dummyATLData), ("TSB", self.graphView.dummyTSBData)]
                self.collapsed = [true, true, false]
            }else{
                let nf: NumberFormatter = NumberFormatter()
                nf.numberStyle = .percent
                let sdnn = data.map({($0.date, $0.sdnn)})
                self.graphData.append((title, sdnn))
                self.collapsed.append(false)
                let hrvGraph: PointGraph = PointGraph(data: sdnn, colour: .magenta, title: "Heart Rate Variability")
                hrvGraph.fill = true
                self.graphView.addGraph(graph: hrvGraph)
                let off = data.map({($0.date, $0.offValue)})
                let tOff: String = "HRV Off (\(nf.string(from: NSNumber(value: HRVDataPoint.hrvOffPercentile)) ?? ""))"
                self.graphData.append((tOff, off))
                self.collapsed.append(false)
                let offGraph: LineGraph = LineGraph(data: off, colour: .white, title: tOff)
                self.graphView.addGraph(graph: offGraph)
                let easy = data.map({($0.date, $0.easyValue)})
                let tEasy: String = "HRV Easy (\(nf.string(from: NSNumber(value: HRVDataPoint.hrvEasyPercentile)) ?? ""))"
                self.graphData.append((tEasy, easy))
                self.collapsed.append(false)
                let easyGraph: LineGraph = LineGraph(data: easy, colour: .cyan, title: tEasy)
                self.graphView.addGraph(graph: easyGraph)
                let hard = data.map({($0.date, $0.hardValue)})
                let tHard: String = "HRV Hard (\(nf.string(from: NSNumber(value: HRVDataPoint.hrvHardPercentile)) ?? ""))"
                self.graphData.append((tHard, hard))
                self.collapsed.append(false)
                let hardGraph: LineGraph = LineGraph(data: hard, colour: .yellow, title: tHard)
                self.graphView.addGraph(graph: hardGraph)
            }
        }
    }
    
    private func createTSBGraph(){
        if selectedTSB == 0{
            createExerciseTSBGraph()
        }else{
            createCalorieGraph()
        }
    }
    
    
    private func createCalorieGraph(){
        titleLabel.text = "Calorie Based TSB"
        HealthKitAccess.shared.getCalorieSummary(dateRange: nil) { (data) in
            if data.count == 0{
                DispatchQueue.main.async {
                    self.requestPermissions()
                    self.titleLabel.text = "Dummy Data"
                }
                self.graphView.removeAllGraphs()
                self.graphView.setGraphs(graphs: [])
                self.graphData = [("CTL", self.graphView.dummyCTLData), ("ATL", self.graphView.dummyATLData), ("TSB", self.graphView.dummyTSBData)]
                self.collapsed = [true, true, false]
            }else{

                let ctlData: [(Date, Double)] = data.map({ (date: $0.date, value: $0.ctl) })
                let atlData: [(Date, Double)] = data.map({ (date: $0.date, value: $0.atl) })
                let tsbData: [(Date, Double)] = data.map({ (date: $0.date, value: $0.tsb) })
                let tssData: [(Date, Double)] = data.map({ (date: $0.date, value: $0.tss)})

                let ctlGraph = LineGraph(data: ctlData, colour: .red, title: "CTL")
                let atlGraph = LineGraph(data: atlData, colour: .green, title: "ATL")
                let tsbGraph = LineGraph(data: tsbData, colour: .yellow, title: "TSB")
                tsbGraph.fill = true
                let tssGraph = PointGraph(data: tssData, colour: .black, title: "TSS")
                self.graphData = [("CTL", ctlData), ("ATL", atlData), ("TSB", tsbData), ("Calories", tssData)]
                self.collapsed = [true, true, true, false]
                self.graphView.setGraphs(graphs: [ctlGraph, atlGraph, tsbGraph, tssGraph])
            }
        }
        
    }

    private func createExerciseTSBGraph(){
        self.titleLabel.text = "Training Stress Balance"
        HealthKitAccess.shared.getExerciseTimeSummary(dateRange: nil) { (data) in
            if data.count == 0{
                DispatchQueue.main.async {
                    // needs to be set on main thread
                    self.requestPermissions()
                    self.graphView.removeAllGraphs()
                    self.graphView.setGraphs(graphs: [])
                    self.graphData = [("CTL", self.graphView.dummyCTLData), ("ATL", self.graphView.dummyATLData), ("TSB", self.graphView.dummyTSBData), ("TSS", self.graphView.dummyTSSData)]
                    self.collapsed = [true, true, true, false]
                    self.tableView.reloadData()
                }
            }else{
                //this data is in hours. For now assume a RPE of 5 using 7 as benchmark for threshol. ie hour at RPE 7 is TSS 100
                //This comes about as estimating TSS from time and rpe we have: TSS ~ (RPE * RPE) * hrs
                //We want RPE 7 to give 100. Thus we have:
                //TSS for 1 hour @ 7 = 100. Thus we want to find factor, f such (7*7)*1*f = 100 => f = 100/49
                //Thus is we're assuming RPE 5 then TSS = Hrs * 5 * 5 * f = hrs * 25 * 100 /49 = hrs * 2500 / 49
                let tssFactor: Double = 2500.0 / 49.0
                var baseTSSData: [(date: Date, value: Double)] = []
                for d in data{
                    baseTSSData.append((date:d.date, value: d.value * tssFactor))
                }
                let trainingStressData = self.createTSBData(from: baseTSSData)
                // just show last 90 days of data
                let ninetyDaysAgo: Date = Calendar.current.date(byAdding: DateComponents(day: -90), to: Date())!
                let filteredData = trainingStressData.filter({$0.date >= ninetyDaysAgo})
                let ctlData: [(Date, Double)] = filteredData.map({ (date: $0.date, value: $0.ctl) })
                let atlData: [(Date, Double)] = filteredData.map({ (date: $0.date, value: $0.atl) })
                let tsbData: [(Date, Double)] = filteredData.map({ (date: $0.date, value: $0.tsb) })
                let tssData: [(Date, Double)] = filteredData.map({ (date: $0.date, value: $0.tss) })

                let ctlGraph = LineGraph(data: ctlData, colour: .red, title: "CTL")
                let atlGraph = LineGraph(data: atlData, colour: .green, title: "ATL")
                let tsbGraph = LineGraph(data: tsbData, colour: .yellow, title: "TSB")
                let tssGraph = PointGraph(data: tssData, colour: .black, title: "TSS")
                tsbGraph.fill = true
                self.graphData = [("CTL", ctlData), ("ATL", atlData), ("TSB", tsbData), ("TSS", tssData)]
                self.collapsed = [true, true, true, false]
                self.graphView.setGraphs(graphs: [ctlGraph, atlGraph, tsbGraph, tssGraph])
            }
        }
    }

    private func createTSBData(from: [(date: Date, value: Double)]) -> [(date: Date, value: Double, ctl: Double, atl: Double, tsb: Double, tss: Double)]{
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
        var result: [(date: Date, value: Double, ctl: Double, atl: Double, tsb: Double, tss: Double)] = []
        let ctlFactor: Double = exp(-1/42.0)
        let atlFactor: Double = exp(-1/7.0)
        for d in gaplessData{
            ctl = d.value * (1 - ctlFactor) + ctl * ctlFactor
            atl = d.value * (1 - atlFactor) + atl * atlFactor
            result.append((date: d.date , value: d.value, ctl: ctl, atl: atl, tsb: ctl-atl, tss: d.value))
        }
        return result
    }
    
    private func updateGraph(forExercise exercise: ExerciseType, andMeasure measure: ExerciseMeasure){
        let title: String  = "\(ExerciseDefinitionManager.shared.exerciseDefinition(for: exercise).name) - \(measure.string())"
        let data: [(Date, Double)] = WorkoutManager.shared.timeSeries(forExeciseType: exercise, andMeasure: measure)
        titleLabel.text = title
        graphView.removeAllGraphs()
        let graph: Graph = PointGraph(data: data , colour: .red, title: measure.string())
        graphData = [(title, data)]
        collapsed = [false]
        graphView.addGraph(graph: graph)
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
        switch selectedGraph{
        case .Ed: return 3
        case .Sets: return 2
        case .TSB: return 1
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch selectedGraph{
        case .Consistency, .HR, .PowerUp:return 0
        case .TSB: return 2
        case .Sets:
            if component == 0{
                return WorkoutManager.shared.exerciseTypes.count
            }else{
                return validMeasures.count
            }
        case .Ed:
            if component == 0{
                return WorkoutManager.shared.exerciseTypes.count
            }else if component == 1{
                return validMeasures.count
            }else{
                return 2
            }
        }
    }
}

extension ProgressViewController: UIPickerViewDelegate{
    

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch selectedGraph {
        case .TSB:
            if row == 0{
                return "Training Stress Balance"
            }else{
                return "Calorie Based TSB"
            }
        case .Sets:
            if component == 0{
                if let def = getSelectedExerciseDefinition(forRow: row){
                    return def.name
                }
            }else{
                return validMeasures[row].string()
            }
        case .Ed:
            if component == 0{
                if let def = getSelectedExerciseDefinition(forRow: row){
                    return def.name
                }
            }else if component == 1{
                return validMeasures[row].string()
            }else{
                if row == 0{
                    return "LTD"
                }else{
                    return "Year"
                }
            }
        default:
            return nil
        }
        return nil
    }
    
    // adjust widths of components. Need for Ed graphs as three components
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch selectedGraph {
        case .Ed:
            let w = pickerView.frame.width
            if component == 2{
                return w * 0.2
            }else{
                return w * 0.4
            }
        default:
            return pickerView.frame.width / 2
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch selectedGraph{
        case .Sets:
            if component == 0{
                selectedExercise = ExerciseType(rawValue: Int16(row)) ?? ExerciseType.gobletSquat
                pickerView.reloadComponent(1)
            }else{
                if row < validMeasures.count{
                    selectedMeasure = validMeasures[row]
                }else{
                    selectedMeasure = .totalReps
                }
            }
            updateGraph(forExercise: selectedExercise, andMeasure: selectedMeasure)
        case .Ed:
            if component == 0{
                selectedExercise = ExerciseType(rawValue: Int16(row)) ?? ExerciseType.gobletSquat
                pickerView.reloadComponent(1)
            }else if component == 1{
                if row < validMeasures.count{
                    selectedMeasure = validMeasures[row]
                }else{
                    selectedMeasure = .totalReps
                }
            }else{
                isLTDEd = row == 0
            }
            createEdGraph()
        case .TSB:
            selectedTSB = row
            createTSBGraph()
        default:
            print("shouldn't hit default clause in pickerView(_: didSelectRow: inComponent:)")
            // do nothing
        }
        tableView.reloadData()
    }
    
    private func getSelectedExerciseDefinition(forRow row: Int) -> ExerciseDefinition?{
        switch selectedGraph{
        case .Consistency, .HR, .TSB, .PowerUp:
            return nil
        case .Sets, .Ed:
            return ExerciseDefinitionManager.shared.exerciseDefinition(for: WorkoutManager.shared.exerciseTypes[row])
        }
    }
}

extension ProgressViewController: UIScrollViewDelegate{
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(pageNumber)
        tableView.reloadData()
    }
}

extension ProgressViewController: UITableViewDelegate{
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section < graphData.count{
//            return graphData[section].title
//        }
//        return "No Title"
//    }
//
}

extension ProgressViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return graphData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < collapsed.count{
            if collapsed[section]{
                return 0
            }
        }
        if section < graphData.count{
            return graphData[section].data.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath)

        cell.textLabel?.text = string(forIndexPath: indexPath)
        cell.textLabel?.font = UIFont(name: "Menlo", size: 15.0)
        cell.backgroundColor = MAIN_BLUE
        cell.textLabel?.textColor = .white
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: DataHeader.reuseIdentifier) else {
            print("returning nil")
            return nil
        }
        if section < graphData.count{
            header.textLabel?.text =  "\(graphData[section].title) : \(graphData[section].data.count) items"
        }
        if let h = header as? DataHeader{
            h.section = section
            h.vc = self
        }

        return header
    }
    
    private func string(forIndexPath indexPath: IndexPath) -> String{
        if indexPath.section < graphData.count{
            let data = graphData[indexPath.section].data
            if indexPath.row < data.count{
                let formattedValue: String = String(format: "%.1f", data[indexPath.row].value)
                return "\(df.string(from: data[indexPath.row].date)) : \(formattedValue)"
            }
        }
        return "No Data"
    }
    
    
}


class DataHeader: UITableViewHeaderFooterView{
    
    static let reuseIdentifier = "DataHeader"
    var section: Int = 0
    fileprivate var vc: ProgressViewController?
    
    override public init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        textLabel?.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecogniser:)))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func viewTapped(gestureRecogniser: UITapGestureRecognizer){
        vc?.toggle(section: section)
    }
}
