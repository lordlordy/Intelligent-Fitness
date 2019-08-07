//
//  InsightReadingsTableViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 06/08/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit

class InsightReadingsTableViewController: UITableViewController {

    var insight: InsightProtocol?
    private var readings: [(date: Date, value: Double)]{ return insight?.insightReadings() ?? []}
    private var formatter: NumberFormatter = NumberFormatter()
    private var df: DateFormatter = DateFormatter()
    private var collapsed: [Bool] = [false, false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.numberStyle = .percent
        df.dateFormat = "E dd-MMM-yy HH:mm:ss"
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.register(ReadingsCollapsableHeader.self, forHeaderFooterViewReuseIdentifier: ReadingsCollapsableHeader.reuseIdentifier)

    }
    
    func toggle(section: Int){
        if section < collapsed.count{
            collapsed[section] = !collapsed[section]
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if let i = insight{
            if i.subInsightsArray().count > 0{
                return 2
            }
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "\(insight?.name() ?? "") - READINGS (\(readings.count))"
        }else{
            return "\(insight?.name() ?? "") - SUB-CATEGORIES (\(insight?.subInsightsArray().count ?? 0))"
        }

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < collapsed.count{
            if collapsed[section]{
                return 0
            }
        }
        if section == 0{
            return readings.count
        }else{
            if let i = insight{
                return i.subInsightsArray().count
            }
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "insightReadingCell", for: indexPath)

        if indexPath.section == 0{
            if indexPath.row < readings.count{
                let r = readings[indexPath.row]
                cell.textLabel?.text = formatter.string(from: NSNumber(value: r.value))
                cell.detailTextLabel?.text = df.string(from: r.date)
            }
        }else{
            if let subCats = insight?.subInsightsArray(){
                if indexPath.row < subCats.count{
                    
                    cell.textLabel?.text = "\(subCats[indexPath.row].name()): \(formatter.string(from: NSNumber(value: subCats[indexPath.row].mostRecentReading().value)) ?? "0%")"
                    cell.detailTextLabel?.text = ""
                    cell.accessoryType = .detailDisclosureButton
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ReadingsCollapsableHeader.reuseIdentifier) else {
            print("returning nil")
            return nil
        }

        if let h = header as? ReadingsCollapsableHeader{
            h.section = section
            h.vc = self
        }
        
        return header
    }
    
    //METHOD TO MAKE DELETION POSSIBLE
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            // note we can't delete sub categories - just readings. Hence only if section 0
            if indexPath.section == 0 && indexPath.row < readings.count{
                if let i = insight{
                    i.removeReading(forDate: readings[indexPath.row].date)
                    tableView.reloadData()
                }
            }
        }else if editingStyle == .insert{
            print("Trying to insert")
        }
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            // selected a sub category
            if let i = insight{
                if let subInsight: InsightProtocol = i.subInsight(atIndex: indexPath.row){
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let vc = storyboard.instantiateViewController(withIdentifier: "readingsViewController") as? InsightReadingsTableViewController{
                        vc.insight = subInsight
                        self.navigationController!.pushViewController(vc, animated: true)
                    }
                    
                }
            }
        }
    }
    
}

class ReadingsCollapsableHeader: UITableViewHeaderFooterView{
    
    static let reuseIdentifier = "ReadingsCollapsableHeader"
    var section: Int = 0
    fileprivate var vc: InsightReadingsTableViewController?
    
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
