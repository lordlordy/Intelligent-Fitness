//
//  InsightsTableViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 06/08/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit

class InsightsTableViewController: UITableViewController {

    private var insights: [PersonalityInsight] = []
    private let formatter: NumberFormatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.numberStyle = .percent
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//         self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        insights = CoreDataStackSingleton.shared.getPersonalityInsights().sorted(by: {$0.type! < $1.type!})
    }
    
    func update(){
        insights = CoreDataStackSingleton.shared.getPersonalityInsights().sorted(by: {$0.type! < $1.type!})
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return insights.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < insights.count{
            return insights[section].insightCount
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < insights.count{
            return insights[section].type ?? "not set"
        }
        return "not set"
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "insightCell", for: indexPath)

        if indexPath.section < insights.count{
            if indexPath.row < insights[indexPath.section].numberOfInsights(){
                if let insight = insights[indexPath.section].getInsight(atIndex: indexPath.row){
                    cell.textLabel?.text = "\(insight.type ?? ""): \(formatter.string(from: NSNumber(value: insight.currentReading.percentile)) ?? "0%")"
                }
            }
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let insight: Insight? = insights[indexPath.section].getInsight(atIndex: indexPath.row)
        performSegue(withIdentifier: "insightReadingsSegue", sender: insight)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "insightReadingsSegue"{
            if let insight = sender as? Insight{
                if let vc = segue.destination as? InsightReadingsTableViewController{
                    vc.insight = insight
                }
            }
        }
    }
    

}
