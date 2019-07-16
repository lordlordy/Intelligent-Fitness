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
    case Consistency = 4
    case Ed = 5

    func name() -> String{
        switch self{
        case .Tests: return "Test Graphs"
        case .Sets: return "Workout Graphs"
        case .HR: return "Heart Rate Graphs"
        case .TSB: return "Training Stress Balance Graphs"
        case .Consistency: return "Weekly Consistency"
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
            return "Training Stress Balance graph. This models your fitness, fatigue and form. This currently uses your activity time from the health app. It assumes an RPE of 5 on average which gives a TSS of ~55 per hour. Can also see a similar graph using active calories as a proxie for TSS"
        case .Consistency:
            return "Shows how many weeks you've done on the trot with 3 sessions per week and no more than 2 rest days between each"
        case .Ed:
            return "A graph of your Eddington numbers. This is a good single number measure of your progress. It gives the maximum KG such that you've lifted that amount on at least that many days. For more info look at http://www.eddingtonnumbers.me.uk"
        }
    }

}

class ProgressViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var graphSegmentedControl: UISegmentedControl!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var toolBar = UIToolbar()
    private var picker = UIPickerView()
    private var selectedGraph: GraphType = .Tests
    private var selectedExercise: Int = 0
    private var selectedMeasure: Int = 0
    private var selectedTSB: Int = 0
    
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CELL_ID)
        tableView.register(DataHeader.self, forHeaderFooterViewReuseIdentifier: DataHeader.reuseIdentifier)
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
        updateGraph(forExercise: ExerciseType(rawValue: Int16(selectedExercise)) ?? ExerciseType.pushUp, andMeasure: ExerciseMeasure(rawValue: selectedMeasure) ?? ExerciseMeasure.avReps)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 2.0, height: scrollView.frame.size.height)
        tableView.frame = CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        tableView.contentSize = CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        graphView.frame.size = CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height)
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
            case .Consistency: createConsistencyGraph()
            case .Ed: createEdGraph()
            case .Sets: createSetsGraph()
            case .HR: createHRGraph()
            case .Tests: createTestsGraph()
            case .TSB: createTSBGraph()
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
    
    private func createConsistencyGraph(){
        chooseButton.isEnabled = true
        chooseButton.isHidden = false
        titleLabel.text = "Consistency"
        print("Consistency")
    }
    
    private func createEdGraph(){
        chooseButton.isEnabled = true
        chooseButton.isHidden = false
        titleLabel.text = "Eddington Numbers"
        print("Ed")
    }
    
    private func createTestsGraph(){
        chooseButton.isEnabled = true
        chooseButton.isHidden = false
        let title: String  = "Functional Fitness Test"
        let data: [(Date, Double)] = WorkoutManager.shared.getExercises(forType: .sittingRisingTest).map({($0.date!, $0.valueFor(exerciseMeasure: .avReps))})
        graphData = [(title, data)]
        collapsed = [false]
        titleLabel.text = title
        graphView.removeAllGraphs()
        let graph: Graph = Graph(data: data, colour: .red)
        graphView.addGraph(graph: graph)
    }
    

    private func createSetsGraph(){
        chooseButton.isEnabled = true
        chooseButton.isHidden = false
        let title: String = "Bench Press"
        let data: [(Date, Double)] = WorkoutManager.shared.getExercises(forType: .benchPress).map({(date: $0.date!, value: $0.valueFor(exerciseMeasure: .maxKG))}).sorted(by: {$0.date < $1.date})
        titleLabel.text = title
        graphData = [(title, data)]
        collapsed = [false]
        graphView.removeAllGraphs()
        graphView.addGraph(graph: Graph(data: data, colour: .red))
    }

    private func createHRGraph(){
        chooseButton.isEnabled = false
        chooseButton.isHidden = true
        let title: String = "Heart Rate Variability"
        titleLabel.text = title
        // remove all graphs
        graphView.removeAllGraphs()
        // the following calls will add graphs
        
        let ninetyDaysAgo: Date = Calendar.current.date(byAdding: DateComponents(day: -90), to: Date())!
        HealthKitAccess.shared.getRestingHRData(dateRange: (from: ninetyDaysAgo, to:Date())) { (data) in
            if data.count > 0{
                self.graphData = [(title, data)]
                self.collapsed = [false]
                self.graphView.addGraph(graph: Graph(data: data, colour: .red))
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
                self.graphData = [(title, data)]
                self.collapsed = [false]
                self.graphView.addGraph(graph: Graph(data: data, colour: .magenta))
            }
        }
    }
    
    private func createTSBGraph(){
        chooseButton.isEnabled = true
        chooseButton.isHidden = false
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
                let trainingStressData = self.createTSBData(from: data)
                // just show last 90 days of data
                let ninetyDaysAgo: Date = Calendar.current.date(byAdding: DateComponents(day: -90), to: Date())!
                let filteredData = trainingStressData.filter({$0.date >= ninetyDaysAgo})
                print(filteredData)
                let ctlData: [(Date, Double)] = filteredData.map({ (date: $0.date, value: $0.ctl) })
                let atlData: [(Date, Double)] = filteredData.map({ (date: $0.date, value: $0.atl) })
                let tsbData: [(Date, Double)] = filteredData.map({ (date: $0.date, value: $0.tsb) })

                let ctlGraph = Graph(data: ctlData, colour: .red)
                let atlGraph = Graph(data: atlData, colour: .green)
                let tsbGraph = Graph(data: tsbData, colour: .yellow)
                tsbGraph.fill = true
                self.graphData = [("CTL", ctlData), ("ATL", atlData), ("TSB", tsbData)]
                self.collapsed = [true, true, false]
                self.graphView.setGraphs(graphs: [ctlGraph, atlGraph, tsbGraph])
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
                    self.graphData = [("CTL", self.graphView.dummyCTLData), ("ATL", self.graphView.dummyATLData), ("TSB", self.graphView.dummyTSBData)]
                    print(self.graphData)
                    self.collapsed = [true, true, false]
                    self.tableView.reloadData()
                }
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
                let trainingStressData = self.createTSBData(from: tssData)
                // just show last 90 days of data
                let ninetyDaysAgo: Date = Calendar.current.date(byAdding: DateComponents(day: -90), to: Date())!
                let filteredData = trainingStressData.filter({$0.date >= ninetyDaysAgo})
                let ctlData: [(Date, Double)] = filteredData.map({ (date: $0.date, value: $0.ctl) })
                let atlData: [(Date, Double)] = filteredData.map({ (date: $0.date, value: $0.atl) })
                let tsbData: [(Date, Double)] = filteredData.map({ (date: $0.date, value: $0.tsb) })

                let ctlGraph = Graph(data: ctlData, colour: .red)
                let atlGraph = Graph(data: atlData, colour: .green)
                let tsbGraph = Graph(data: tsbData, colour: .yellow)
                tsbGraph.fill = true
                self.graphData = [("CTL", ctlData), ("ATL", atlData), ("TSB", tsbData)]
                self.collapsed = [true, true, false]
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
        let title: String  = "\(ExerciseDefinitionManager.shared.exerciseDefinition(for: exercise).name) - \(measure.string())"
        let data: [(Date, Double)] = WorkoutManager.shared.getExercises(forType: exercise).map({($0.date!, $0.valueFor(exerciseMeasure: measure))}).sorted(by: {$0.0 < $1.0})
        titleLabel.text = title
        graphView.removeAllGraphs()
        let graph: Graph = Graph(data: data , colour: .red)
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
        case .Sets, .Tests: return 2
        case .TSB: return 1
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch selectedGraph{
        case .Consistency, .HR:return 0
        case .TSB: return 2
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
        switch selectedGraph {
        case .TSB:
            if row == 0{
                return "Training Stress Balance"
            }else{
                return "Calorie Based TSB"
            }
        case .Tests, .Sets:
            if component == 0{
                if let def = getSelectedExerciseDefinition(forRow: row){
                    return def.name
                }
            }else{
                return ExerciseMeasure(rawValue: row)?.string()
            }
        default:
            return nil
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch selectedGraph{
        case .Sets, .Tests:
            if component == 0{
                selectedExercise = row
            }else{
                selectedMeasure = row
            }
            if selectedGraph == .Tests{
                if let measure = ExerciseMeasure(rawValue: selectedMeasure){
                    updateGraph(forExercise: WorkoutManager.shared.fftTypes[selectedExercise], andMeasure: measure)
                }
            }else if selectedGraph == .Sets{
                if let measure = ExerciseMeasure(rawValue: selectedMeasure){
                    updateGraph(forExercise: WorkoutManager.shared.exerciseTypes[selectedExercise], andMeasure: measure)
                }
            }
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
        case .Consistency, .HR, .TSB, .Ed:
            return nil
        case .Sets:
            return ExerciseDefinitionManager.shared.exerciseDefinition(for: WorkoutManager.shared.exerciseTypes[row])
        case .Tests:
            return ExerciseDefinitionManager.shared.exerciseDefinition(for: WorkoutManager.shared.fftTypes[row])
        }
    }
}

extension ProgressViewController: UIScrollViewDelegate{
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(pageNumber)
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
        print("\(String(describing: textLabel?.text)) TAPPED")
        vc?.toggle(section: section)
    }
}
