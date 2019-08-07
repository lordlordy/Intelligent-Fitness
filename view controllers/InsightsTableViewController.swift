//
//  InsightsTableViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 06/08/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit

class InsightsTableViewController: UITableViewController {

    private var insights: [InsightCategoryProtocol] = []
    private let formatter: NumberFormatter = NumberFormatter()
    private var collapsed: [Bool] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.numberStyle = .percent
        tableView.register(InsightsCollapsableHeader.self, forHeaderFooterViewReuseIdentifier: InsightsCollapsableHeader.reuseIdentifier)
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
////        insights = CoreDataStackSingleton.shared.getPersonalityInsights().sorted(by: {$0.type! < $1.type!})
//
//    }
    
    func toggle(section: Int){
        if section < collapsed.count{
            collapsed[section] = !collapsed[section]
            tableView.reloadData()
        }
    }
    
    func set(insights: [InsightCategoryProtocol]){
        self.insights = insights.sorted(by: {$0.categoryName() < $1.categoryName()})
        collapsed = []
        for _ in insights{
            collapsed.append(false)
        }
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return insights.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < collapsed.count{
            if collapsed[section]{
                return 0
            }
        }
        if section < insights.count{
            return insights[section].numberOfInsights()
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < insights.count{
            return insights[section].categoryName()
        }
        return "not set"
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "insightCell", for: indexPath)

        if indexPath.section < insights.count{
            if indexPath.row < insights[indexPath.section].numberOfInsights(){
                if let insight = insights[indexPath.section].insight(atIndex: indexPath.row){
                    cell.textLabel?.text = "\(insight.name()): \(formatter.string(from: NSNumber(value: insight.mostRecentReading().value)) ?? "0%")"
                }
            }
        }
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: InsightsCollapsableHeader.reuseIdentifier) else {
            print("returning nil")
            return nil
        }
        
        if let h = header as? InsightsCollapsableHeader{
            h.section = section
            h.vc = self
        }
        
        return header
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let insight: InsightProtocol? = insights[indexPath.section].insight(atIndex: indexPath.row)
        performSegue(withIdentifier: "insightReadingsSegue", sender: insight)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "insightReadingsSegue"{
            if let insight = sender as? InsightProtocol{
                if let vc = segue.destination as? InsightReadingsTableViewController{
                    vc.insight = insight
                }
            }
        }
    }
    

}

class InsightsCollapsableHeader: UITableViewHeaderFooterView{
    
    static let reuseIdentifier = "InsightsCollapsableHeader"
    var section: Int = 0
    fileprivate var vc: InsightsTableViewController?
    
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
