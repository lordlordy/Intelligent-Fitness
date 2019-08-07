//
//  WeekTableViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 31/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit

class WeekTableViewController: UITableViewController {

    var week: Week?
    private var df: DateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        df.dateFormat = "EEEE dd-MMM"

         self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 7
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let wk = week{
            return df.string(from: wk.date(forDayOfWeek: section))
        }else{
            return "No week defined"
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let wk = week{
            let c = wk.workouts(forDayOfWeek: section).count
            if c > 0{
                return c
            }else{
                // always have one cell as will note it's a rest day if there are no workouts
                return 1
            }
        }else{
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let wk = week{
            let workouts = wk.workouts(forDayOfWeek: indexPath.section)
            if indexPath.row < workouts.count{
                let cell = tableView.dequeueReusableCell(withIdentifier: "workoutCell", for: indexPath)
                if let c = cell as? WorkoutCellView{
                    c.workout = workouts[indexPath.row]
                }
                return cell
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "restDayCell", for: indexPath)
        return cell
    }
 
    //METHOD TO MAKE DELETION POSSIBLE
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            if let cell = self.tableView(tableView, cellForRowAt: indexPath) as? WorkoutCellView{
                CoreDataStackSingleton.shared.delete(cell.workout!)
                CoreDataStackSingleton.shared.save()
                tableView.reloadData()
            }
        }else if editingStyle == .insert{
            print("Trying to insert")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = self.tableView(tableView, cellForRowAt: indexPath) as? WorkoutCellView{
            performSegue(withIdentifier: "showWorkout", sender: cell.workout)
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let w = sender as? Workout{
            if let vc = segue.destination as? WorkoutDetailTableViewController{
                vc.workout = w
            }
        }
    }
}

class WorkoutCellView: UITableViewCell{
    var workout: Workout?{
        didSet{
            textLabel?.text = workout!.workoutType()?.string()
            detailTextLabel?.text = workout!.summary()
        }
    }
    
}
