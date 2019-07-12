//
//  WorkoutDetailTableViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 11/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit

class WorkoutDetailTableViewController: UITableViewController {

    var workout: Workout?
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return workout?.exercises?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let e = workout?.exercise(atOrder: Int16(section)){
            return e.numberOfSets()
        }else{
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let e = workout?.exercise(atOrder: Int16(section)){
            let f: NumberFormatter = NumberFormatter()
            f.numberStyle = .percent
            var str: String  = "\(e.exerciseDefinition().name) - "
            if e.totalActualKG > 0{
                str  += "\(Int(e.totalActualKG))kg"
            }
            str += " \(f.string(from: NSNumber(value: e.percentageComplete)) ?? "") "
            return str
        }else{
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SetCell", for: indexPath)

        if let es = exerciseSet(atIndexPath: indexPath){
            cell.textLabel?.text = es.summary()
        }
        
        
        return cell
    }
 
    private func exerciseSet(atIndexPath indexPath: IndexPath) -> ExerciseSet?{
        return workout?.exercise(atOrder: Int16(indexPath.section))?.exerciseSet(atOrder: Int16(indexPath.row))
    }



}
