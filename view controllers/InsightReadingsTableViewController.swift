//
//  InsightReadingsTableViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 06/08/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit

class InsightReadingsTableViewController: UITableViewController {

    var insight: Insight?
    private var readings: [InsightReading]{ return insight?.insightReadingArray ?? []}
    private var formatter: NumberFormatter = NumberFormatter()
    private var df: DateFormatter = DateFormatter()
    private var collapsed: [Bool] = [false, false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.numberStyle = .percent
        df.dateFormat = "E dd-MM-yy hh:mm:ss"
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.register(CollapsableHeader.self, forHeaderFooterViewReuseIdentifier: CollapsableHeader.reuseIdentifier)

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
            if i.subInsightArray.count > 0{
                return 2
            }
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "\(insight?.type ?? "") - READINGS" : "\(insight?.type ?? "") - SUB-CATEGORIES"
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
                return i.subInsightArray.count
            }
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "insightReadingCell", for: indexPath)

        if indexPath.section == 0{
            if indexPath.row < readings.count{
                let r = readings[indexPath.row]
                cell.textLabel?.text = formatter.string(from: NSNumber(value: r.percentile))
                cell.detailTextLabel?.text = df.string(from: r.date!)
            }
        }else{
            if let subCats = insight?.subInsightArray{
                if indexPath.row < subCats.count{
                    
                    cell.textLabel?.text = "\(subCats[indexPath.row].type ?? ""): \(formatter.string(from: NSNumber(value: subCats[indexPath.row].currentReading.percentile)) ?? "0%")"
                    cell.detailTextLabel?.text = ""
                    cell.accessoryType = .detailDisclosureButton
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CollapsableHeader.reuseIdentifier) else {
            print("returning nil")
            return nil
        }

        if let h = header as? CollapsableHeader{
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
                    i.remove(insightReading: readings[indexPath.row])
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
                if let subInsight: Insight = i.subCategory(atIndex: indexPath.row){
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let vc = storyboard.instantiateViewController(withIdentifier: "readingsViewController") as? InsightReadingsTableViewController{
                        vc.insight = subInsight
                        self.navigationController!.pushViewController(vc, animated: true)
                    }
                    
                }
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}

class CollapsableHeader: UITableViewHeaderFooterView{
    
    static let reuseIdentifier = "CollapsableHeader"
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
        print("\(String(describing: textLabel?.text)) TAPPED")
        vc?.toggle(section: section)
    }
}
