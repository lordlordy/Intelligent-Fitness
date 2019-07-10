//
//  HistoryViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 27/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit

fileprivate protocol Collapsable{
    func toggleSectionForName(_ name: HistoryViewController.HistorySection)
    func reload()
}

class HistoryViewController: UITableViewController, Collapsable {

    enum HistorySection: Int{
        case Test = 0
        case Workout = 1
        
        func name() -> String{
            switch self{
            case .Test: return "Tests"
            case .Workout: return "Workouts"
            }
        }
    }
    
    private var tests: [TestSet] = []
    private var workouts: [Workout] = []
    private var df: DateFormatter = DateFormatter()
    
    private var testsCollapsed: Bool = false
    private var workoutsCollapsed: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        df.dateFormat = "dd-MM-yyyy"
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        self.navigationItem.rightBarButtonItem = self.editButtonItem

        self.tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.tableView.register(CustomHeader.self, forHeaderFooterViewReuseIdentifier: CustomHeader.reuseIdentifier)

    }
    
    func toggleSectionForName(_ name: HistoryViewController.HistorySection) {
        
        switch name{
        case .Test:
            testsCollapsed = !testsCollapsed
        case .Workout:
            workoutsCollapsed = !workoutsCollapsed
        }
    }
    
    func reload() {
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //get history
        tests = CoreDataStackSingleton.shared.getTestSets()
        workouts = CoreDataStackSingleton.shared.getWorkouts()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == HistorySection.Test.rawValue{
            if testsCollapsed{
                return 0
            }else{
                return tests.count
            }
        }else if section == HistorySection.Workout.rawValue{
            if workoutsCollapsed{
                return 0
            }else{
                return workouts.count
            }
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CustomHeader.reuseIdentifier) else {
            print("returning nil")
            return nil
        }
        if section == HistorySection.Test.rawValue{
            header.textLabel?.text = HistorySection.Test.name()
        }else{
            header.textLabel?.text = HistorySection.Workout.name()
        }
        if let c = header as? CustomHeader{
            c.section = self
        }
        return header
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "functionalFitnessTest", for: indexPath)

        if indexPath.section == HistorySection.Test.rawValue{
            cell.textLabel?.text = String("\(df.string(from: tests[indexPath.row].date ?? Date())) - Test")
            cell.detailTextLabel?.text = tests[indexPath.row].summaryString()
        }else{
            let w: Workout = workouts[indexPath.row]
            cell.textLabel?.text = df.string(from: w.date! ) + " " + w.type!
        }

        return cell
    }
    
    //METHOD TO MAKE DELETION POSSIBLE
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            print("Trying to delete")
            if indexPath.section == HistorySection.Test.rawValue{
                //deleting a test
                let testToDelete: TestSet = tests[indexPath.row]
                tests.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                CoreDataStackSingleton.shared.delete(testToDelete)
            }else if indexPath.section == HistorySection.Workout.rawValue{
                //deleting a workout
                let workoutToDelete: Workout = workouts[indexPath.row]
                workouts.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                CoreDataStackSingleton.shared.delete(workoutToDelete)

            }
        }else if editingStyle == .insert{
            print("Trying to insert")
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
//        super.tableView(tableView, accessoryButtonTappedForRowWith: indexPath)
        print("detail TAPPED")
    }

}

class CustomHeader: UITableViewHeaderFooterView{
    
    static let reuseIdentifier = "Custom"
    fileprivate var section: Collapsable?
    let label = UILabel.init()
    
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
        if let s = section{
            if textLabel?.text == HistoryViewController.HistorySection.Test.name(){
                s.toggleSectionForName(HistoryViewController.HistorySection.Test)
            }else if textLabel?.text == HistoryViewController.HistorySection.Workout.name(){
                s.toggleSectionForName(HistoryViewController.HistorySection.Workout)
            }
            s.reload()
        }
    }
}