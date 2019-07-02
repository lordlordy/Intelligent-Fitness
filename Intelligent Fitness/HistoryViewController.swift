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
//    @IBOutlet var tableView: UITableView!
    
    private var tests: [FunctionalFitnessTest] = []
    private var workouts: [String] = ["w1", "w2", "w3"]
    private var df: DateFormatter = DateFormatter()
    
    private var testsCollapsed: Bool = false
    private var workoutsCollapsed: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        df.dateFormat = "dd-MM-yyyy"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

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
        tests = CoreDataStackSingleton.shared.getFunctionFitnessTests()
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
//
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == HistorySection.Test.rawValue{
//            return "Tests"
//        }else{
//            return "Workouts"
//        }
//    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        print("getting custom header")
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CustomHeader.reuseIdentifier) else {
            print("returning nil")
            return nil
        }
//        let header = tableView.dequeueReusableCell(withIdentifier: "functionalFitnessTest")
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
    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 20.0
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        print(indexPath)
        print("row: \(indexPath.row)")
        print("seciotn: \(indexPath.section)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "functionalFitnessTest", for: indexPath)

        if indexPath.section == HistorySection.Test.rawValue{
            cell.textLabel?.text = String("\(df.string(from: tests[indexPath.row].date!)) - Test")
            cell.detailTextLabel?.text = tests[indexPath.row].summaryString()
        }else{
            cell.textLabel?.text = workouts[indexPath.row]
        }

        return cell
    }

}

class CustomHeader: UITableViewHeaderFooterView{
    
    static let reuseIdentifier = "Custom"
    fileprivate var section: Collapsable?
    let label = UILabel.init()
    
    override public init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        textLabel?.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        
//        detailTextLabel?.text = "Tap to hide"
//        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        self.contentView.addSubview(label)
        
//        let margins = contentView.layoutMarginsGuide
//        label.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
//        label.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
//        label.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
//        label.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
//        label.text = "This is a TEST"
        
        
        
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
