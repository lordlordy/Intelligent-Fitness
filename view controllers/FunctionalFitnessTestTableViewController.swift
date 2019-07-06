//
//  FunctionalFitnessTestTableViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 03/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit

class FunctionalFitnessTestTableViewController: UITableViewController {

    enum TimerStatus: Int{
        case Initial = 0
        case Started = 1
        case Stopped = 2
        case Next = 3

        func nextStatus() -> TimerStatus{
            return TimerStatus(rawValue: (self.rawValue + 1) % 4)!
        }
        
        func string() -> String{
            switch self{
            case .Initial: return "Start"
            case .Started: return "Stop"
            case .Stopped: return "Next Test"
            case .Next: return "Done"
            }
        }
    }
    
    private let kgRow: Int = 3
    private let timerRow: Int = 7
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = super.tableView(tableView, heightForRowAt: indexPath)
        if indexPath.row == timerRow && !(fitnessTest.test(atOrder: currentTest)?.testType().isTimed() ?? true){
            return 0.0
        }else if indexPath.row == kgRow && !(fitnessTest.test(atOrder: currentTest)?.testType().hasKG() ?? true){
            return 0.0
        }
        return height
    }
    
    @IBOutlet weak var testName: UILabel!
    @IBOutlet weak var testDescription: UITextView!
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var result: UITextField!
    @IBOutlet weak var previousResult: UITextField!
    @IBOutlet weak var goalResult: UITextField!
    @IBOutlet weak var progressTextField: UITextView!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var kgField: UITextField!
    
    
    @IBAction func minusKG(_ sender: Any) {
        kgField.text = String(max(0, (kgField.text! as NSString).doubleValue - 1.0))
    }
    
    @IBAction func plusKG(_ sender: Any) {
        kgField.text = String((kgField.text! as NSString).doubleValue + 1.0)
    }
    
    
    private var timer: Timer?
    private var startTime: Date = Date()
    private var runningTime: TimeInterval = TimeInterval()
    private var timerStatus: TimerStatus = .Initial
    private var nonEditableColour: UIColor = .clear
    private var editableColour: UIColor = .white
    
    var targetSeconds: Double = 30
    var lastTestSeconds: Double = 10
    
    var fitnessTest: TestSet = WorkoutManager().createFunctionalFitnessTest()
    private var currentTest: Int16 = 0
    private var testCompleted: Bool = false
    
    private func nextTest(){
        currentTest += 1
        updateTest()
    }
    
    @IBAction func startStopTimer(_ sender: Any) {
        if testCompleted{
            print("need to save the test here")
            performSegue(withIdentifier: "EndOfTest", sender: self)
        }
        timerStatus = timerStatus.nextStatus()
        startStopButton.setTitle(timerStatus.string(), for: .normal)
        switch timerStatus{
        case .Initial:
            return
        case .Started:
            if timer != nil{
                // theres one running don't start another
                return
            }
            timer = Timer(timeInterval: 0.1,
                          target: self,
                          selector: #selector(updateTimer),
                          userInfo: nil,
                          repeats: true)
            startTime = Date()
            RunLoop.current.add(timer!, forMode: .common)
            timer!.tolerance = 0.1
        case .Stopped:
            if let t = timer{
                t.invalidate()
                timer = nil
            }
        case .Next:
            nextTest()
            return
        }
    }
    
    @objc func updateTimer(){
        runningTime = Date().timeIntervalSince(startTime)
        let seconds = Int(runningTime)
        let subSeconds = Int((runningTime - Double(Int(runningTime))) * 10)
        elapsedTimeLabel.text = "\(seconds).\(subSeconds)"
        progressView.progress = Float(runningTime / targetSeconds)
        progressView.secondaryProgress = Float(runningTime / lastTestSeconds)
        result.text = "\(Int(runningTime.rounded()))s"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        if view.backgroundColor?.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) ?? false{
            nonEditableColour = UIColor(hue: hue, saturation: saturation, brightness: brightness * 1.1, alpha: alpha)
        }
        previousResult.backgroundColor = nonEditableColour
        previousResult.textColor = .white
        goalResult.backgroundColor = nonEditableColour
        goalResult.textColor = .white
        
        updateTest()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecogniser:)))
        view.addGestureRecognizer(tapGesture)
        
    }

    @objc func viewTapped(gestureRecogniser: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Tab bar preparing for segue")
        super.prepare(for: segue, sender: sender)
        print(segue.identifier)
        if segue.identifier == "EndOfTest" {
            if let tabVC = segue.destination as? UITabBarController{
                tabVC.selectedIndex = 3
            }
        }
        
    }
    
    
    private func updateTest(){
        if let test = fitnessTest.test(atOrder: currentTest){
            testName.text = test.testType().rawValue
            testDescription.text = test.description()
            progressView.progress = 0.0
            progressView.secondaryProgress = 0.0
            result.text = ""
            elapsedTimeLabel.text = ""
            if test.getGoalOrDefault() < 0{
                goalResult.text = ""
            }else{
                goalResult.text = String(test.getGoalOrDefault())
            }
            kgField.text = String(test.kg)
            if test.testType().isTimed(){
                timerStatus = .Initial
                result.backgroundColor = nonEditableColour
                result.textColor = .white
                result.isEnabled = false
            }else{
                timerStatus = .Stopped
                result.backgroundColor = editableColour
                result.textColor = view.backgroundColor
                result.isEnabled = true
            }
            if currentTest == fitnessTest.numberOfTests() - 1{
                // it's the last test
                startStopButton.setTitle("Save Test", for: .normal)
                testCompleted = true
            }else{
                startStopButton.setTitle(timerStatus.string(), for: .normal)
            }

            tableView.reloadData()
        }
    }
}
