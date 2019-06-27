//
//  HistoryViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 27/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit

class HistoryViewController: UITableViewController {

    enum HistorySection: Int{
        case Test = 0
        case Workout = 1
    }
//    @IBOutlet var tableView: UITableView!
    
    private var tests: [FunctionalFitnessTest] = []
    private var workouts: [String] = ["w1", "w2", "w3"]
    private var df: DateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        df.dateFormat = "dd-MM-yyyy"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //get history
        tests = CoreDataStackSingleton.shared.getFunctionFitnessTests()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == HistorySection.Test.rawValue{
            return tests.count
        }else if section == HistorySection.Workout.rawValue{
            return workouts.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == HistorySection.Test.rawValue{
            return "Tests"
        }else{
            return "Workouts"
        }
    }

    
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


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
