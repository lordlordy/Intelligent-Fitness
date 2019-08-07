//
//  InsightsGraphViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 06/08/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit

class InsightsGraphViewController: UIViewController {

    @IBOutlet weak var graphView: GraphView!
    private var insights: [InsightCategoryProtocol] = []
    private var selectedInsight: Int = 0
    private var selectedSubInsight: Int?
    private let colourArray: [UIColor] = [.red, .orange, .purple, .yellow, .green, .magenta, .cyan, .black, .white, .brown, .darkGray, .lightGray, .blue, .gray]
    private var picker = UIPickerView()
    private var toolBar = UIToolbar()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateGraphs()
        
        picker.backgroundColor = MAIN_BLUE
        picker.dataSource = self
        picker.delegate = self
        picker.setValue(UIColor.white, forKey: "textColor")
        picker.contentMode = .center
        picker.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        toolBar.backgroundColor = MAIN_BLUE
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecogniser:)))
        graphView.addGestureRecognizer(tapGesture)
    }
    
    @objc func viewTapped(gestureRecogniser: UITapGestureRecognizer){
        self.view.addSubview(picker)
        self.view.addSubview(toolBar)
    }
    
    @objc func onDoneButtonTapped(){
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
    }
    
    func set(insights: [InsightCategoryProtocol]){
        self.insights = insights
        if graphView != nil{
            updateGraphs()
        }
    }

    private func updateGraphs(){
        if insights.count > 0{
            graphView.removeAllGraphs()
            var graphs: [Graph] = []
            var count: Int = 0
            var iArray: [InsightProtocol] = insights[selectedInsight].insightsArray()
            if let sub = selectedSubInsight{
                iArray = insights[selectedInsight].insight(atIndex: sub)?.subInsightsArray() ?? []
            }
            for i in iArray{
                let g: Graph = LineGraph(data: i.insightReadings(), colour: colourArray[count], title: i.name())
                count += 1
                graphs.append(g)
            }
            graphView.setGraphs(graphs: graphs)
        }
    }
    
    private func anySubInsights() -> Bool{
        for i in insights{
            if i.hasSubInsights(){
                return true
            }
        }
        return false
    }
    

}

extension InsightsGraphViewController: UIPickerViewDelegate{
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            if row < insights.count{
                return insights[row].categoryName()
            }
        }else{
            if row == 0{
                return "All"
            }else{
                if (row - 1) < insights[selectedInsight].numberOfInsights(){
                    return insights[selectedInsight].insight(atIndex: row-1)?.name()
                }
            }
        }
        return nil
    }
    
    // adjust widths of components. Need for Ed graphs as three components
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if anySubInsights(){
            if component == 0{
                return pickerView.frame.width / 3
            }else{
                return pickerView.frame.width * 2 / 3
            }
        }else{
            return pickerView.frame.width
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0{
            selectedInsight = row
            if anySubInsights(){
                pickerView.reloadComponent(1)
            }
        }else{
            if row == 0{
                selectedSubInsight = nil
            }else{
                selectedSubInsight = row - 1
            }
        }
        updateGraphs()
    }
    
}

extension InsightsGraphViewController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return anySubInsights() ? 2 : 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0{
            return insights.count
        }else{
            if insights[selectedInsight].hasSubInsights(){
                return insights[selectedInsight].insightsArray().count + 1
            }else{
                return 1
            }
        }
    }
}
