//
//  HistoryViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 27/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit

class HistoryViewController: UITableViewController {
    
    private var weeks: [Week] = []
    private var df: DateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        df.dateFormat = "E dd-MMM"

        self.clearsSelectionOnViewWillAppear = false
        self.tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    }
    
//    func reload() {
//        tableView.reloadData()
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        weeks = WorkoutManager.shared.getWeeks().sorted(by: {$0.startOfWeek > $1.startOfWeek})
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weeks.count
    }

    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Weeks"
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "weekCell", for: indexPath)
        let week: Week = weeks[indexPath.row]
        cell.textLabel?.text = "\(week.weekStr): \(df.string(from: week.startOfWeek)) - \(df.string(from: week.endOfWeek))"
        cell.detailTextLabel?.text = week.summary

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showWeek", sender: weeks[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWeek"{
            if let d = segue.destination as? WeekTableViewController{
                if let w = sender as? Week{
                    d.week = w
                }
            }
        }
    }

}
