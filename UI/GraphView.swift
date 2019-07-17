//
//  GraphView.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 25/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit

class Graph{
    var data: [(date: Date, value: Double)]
    var colour: UIColor
    var fill: Bool = false
    var invertFill: Bool = false
    
    var max: Double {
        return data.map({ (datum) -> Double in
            datum.value
        }).max() ?? 0.0
    }
    
    var min: Double{
        return data.map({ (datum) -> Double in
            datum.value
        }).min() ?? 0.0
    }
    
    init(data: [(Date, Double)], colour: UIColor) {
        self.data = data
        self.colour = colour
    }
    
}

// TO DO - this class assumes the x axis points are equal distance apart. eg assumes we have y data for all days. Need to plot correctly even if days are missing
// TO DO - ensure doesn't throw exception if not enough data points. Check if data has just one point
@IBDesignable class GraphView: UIView {

    private struct Constants {
        static let cornerRadiusSize = CGSize(width: 8.0, height: 8.0)
        static let margin: CGFloat = 20.0
        static let topBorder: CGFloat = 20.0
        static let bottomBorder: CGFloat = 30.0
        static let colorAlpha: CGFloat = 0.3
        static let circleDiameter: CGFloat = 5.0
        static let labelFontSize: CGFloat = 12.0
    }

    // colours for gradient.
    @IBInspectable var startColour: UIColor = MAIN_BLUE
    @IBInspectable var endColour: UIColor = .white
    
    private var graphs: [Graph] = []
    private var labels: [UITextField] = []
    
    //    dummy data
    var dummyCTLData: [(Date, Double)] = []
    var dummyATLData: [(Date, Double)] = []
    var dummyTSBData: [(Date, Double)] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createDummyData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setGraphs(graphs: [Graph]){
        self.graphs = graphs
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
    
    func addGraph(graph: Graph){
        graphs.append(graph)
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
    
    func removeAllGraphs(){
        self.graphs = []
    }
    
    override func draw(_ rect: CGRect) {
        
        if graphs.count == 0{
            graphs = getDummyGraphs()
        }
        
        let context = UIGraphicsGetCurrentContext()!
        let colors = [startColour.cgColor, endColour.cgColor]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let colorLocations: [CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)!
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: self.bounds.height)
        context.drawLinearGradient(gradient,
                                   start: startPoint,
                                   end: endPoint,
                                   options: CGGradientDrawingOptions(rawValue: 0))
        
        for g in graphs{
            addGraph(rect, graph: g)
        }
        
        addHorizontalLines(rect)
        
    }
    
    fileprivate func addHorizontalLines(_ rect: CGRect){
        //remove old labels
        for l in labels{
            l.removeFromSuperview()
        }
        labels = []
        
        let min = minY()
        let max = maxY()
        let middle = (min<0.0) ? (max / 2.0) : ((max-min)/2.0)
   
        var line = UIBezierPath()
        // max
        var yCoord: CGFloat = graphYToRectCoordinate(rect, CGFloat(max))
        line.move(to: CGPoint(x: Constants.margin, y: yCoord))
        line.addLine(to: CGPoint(x: rect.width - Constants.margin, y: yCoord))
        let maxLabel = createLabel(value: String(Int(max)), origin: CGPoint(x: 0.0, y: yCoord - Constants.margin/2.0), size: CGSize(width: Constants.margin*2, height: Constants.margin))
        addSubview(maxLabel)
        labels.append(maxLabel)
        // middle
        yCoord = graphYToRectCoordinate(rect, CGFloat(middle))
        line.move(to: CGPoint(x: Constants.margin, y: yCoord))
        line.addLine(to: CGPoint(x: rect.width - Constants.margin, y: yCoord))
        let middleLabel = createLabel(value: String(Int(middle)), origin: CGPoint(x: 0.0, y: yCoord - Constants.margin/2.0), size: CGSize(width: Constants.margin*2, height: Constants.margin))
        addSubview(middleLabel)
        labels.append(middleLabel)
        UIColor.white.setStroke()
        line.lineWidth = 1.0
        line.stroke()
        
        //min
        line = UIBezierPath()
        yCoord = graphYToRectCoordinate(rect, CGFloat(min))
        line.move(to: CGPoint(x: Constants.margin, y: yCoord))
        line.addLine(to: CGPoint(x: rect.width - Constants.margin, y: yCoord))
        let minLabel = createLabel(value: String(Int(min)), origin: CGPoint(x: 0.0, y: yCoord - Constants.margin/2.0), size: CGSize(width: Constants.margin*2, height: Constants.margin))
        addSubview(minLabel)
        labels.append(minLabel)
        startColour.setStroke()
        line.lineWidth = 1.0
        line.stroke()
        
        if min < 0.0{
            // put in zero line
            let xAxis = UIBezierPath()
            let y = graphYToRectCoordinate(rect, 0.0)
            print(y)
            xAxis.move(to: CGPoint(x: Constants.margin, y: y))
            xAxis.addLine(to: CGPoint(x: rect.width - Constants.margin, y: y))
            let zeroLabel = createLabel(value: "0", origin: CGPoint(x: 0.0, y: y - Constants.margin/2.0), size: CGSize(width: Constants.margin*2, height: Constants.margin))
            addSubview(zeroLabel)
            labels.append(zeroLabel)
            UIColor.black.setStroke()
            xAxis.lineWidth = 1.0
            xAxis.stroke()
        }
        
        
    }

    fileprivate func addGraph(_ rect: CGRect, graph: Graph) {
        
        if graph.data.count == 0{
            return
        }
        
        let width = rect.width
        let height = rect.height
        //calculate the x point
        let margin = Constants.margin
        // nb this is a function
        let columnXPoint = { (column:Int) -> CGFloat in
            //Calculate gap between points
            let spacer = (width - margin * 2 - 4) / CGFloat((graph.data.count - 1))
            var x: CGFloat = CGFloat(column) * spacer
            x += margin + 2
            return x
        }
        
        // calculate the y point
        let topBorder: CGFloat = Constants.topBorder
        let bottomBorder: CGFloat = Constants.bottomBorder
        let graphHeight = height - topBorder - bottomBorder
        let maxValue = maxY()
        let minValue = minY()
        let yRange = max(0.1, CGFloat(maxValue - minValue))
        // again this is a function
        let columnYPoint = { (graphPoint:Double) -> CGFloat in
            var y:CGFloat = CGFloat(graphPoint - minValue) / yRange * graphHeight
            y = graphHeight + topBorder - y // Flip the graph
            return y
        }
        
        // draw the line graph
        graph.colour.setFill()
        graph.colour.setStroke()
        
        //set up the points line
        let graphPath = UIBezierPath()
        //go to start of line
        graphPath.move(to: CGPoint(x:columnXPoint(0), y:columnYPoint(graph.data[0].value)))

        //add points for each item in the graphPoints array
        //at the correct (x, y) for the point
        for i in 1..<graph.data.count {
            let nextPoint = CGPoint(x:columnXPoint(i), y:columnYPoint(graph.data[i].value))
            graphPath.addLine(to: nextPoint)
        }
        
        //draw the line on top of the clipped gradient
        graphPath.lineWidth = 2.0
        graphPath.stroke()

        if graph.fill{
            UIGraphicsGetCurrentContext()?.saveGState()
            let cPath = graphPath.copy() as! UIBezierPath
            cPath.addLine(to: CGPoint(x:columnXPoint(graph.data.count-1), y:columnYPoint(0.0)))
            cPath.addLine(to: CGPoint(x:columnXPoint(0), y:columnYPoint(0.0)))
            cPath.close()
            cPath.addClip()
            
            var sColour: CGColor = startColour.cgColor
            var eColour: CGColor = endColour.cgColor
            
            if graph.invertFill{
                sColour = endColour.cgColor
                eColour = startColour.cgColor
            }

            var colours = (graph.max > 0) ? [sColour, eColour] : [eColour, sColour]
            var colourLocations: [CGFloat] = [0.0, 1.0]
            let colourSpace = CGColorSpaceCreateDeviceRGB()
            if graph.min < 0 && graph.max > 0{
                colours = [sColour, eColour, sColour]
                colourLocations = [0.0, (columnYPoint(0)-columnYPoint(graph.max))/(columnYPoint(graph.min)-columnYPoint(graph.max)) , 1.0]
                print(colourLocations)
            }
            if let gradient = CGGradient(colorsSpace: colourSpace,
                                         colors: colours as CFArray,
                                         locations: colourLocations){
                let context = UIGraphicsGetCurrentContext()!
                let max = (graph.max < 0) ? 0.0 : graph.max
                context.drawLinearGradient(gradient, start: CGPoint(x: margin, y: columnYPoint(max)), end: CGPoint(x: margin, y: columnYPoint(graph.min)), options: [])

            }
            UIGraphicsGetCurrentContext()?.restoreGState()
        }
        
    }
    
    private func graphYToRectCoordinate(_ rect: CGRect, _ graphPoint: CGFloat) -> CGFloat{
        let minValue: CGFloat = CGFloat(minY())
        let maxValue: CGFloat = CGFloat(maxY())
        let yRange = max(0.1, maxValue - minValue)
        let graphHeight = rect.height - Constants.topBorder - Constants.bottomBorder
        
        var y:CGFloat = (graphPoint - minValue) / yRange * graphHeight
        y = graphHeight + Constants.topBorder - y // Flip the graph
        return y
    }
    
    
    private func maxY() -> Double{
        //checks all graphs for the max value
        return graphs.map({ (g) -> Double in
            g.max
        }).max() ?? 0.0
    }
    
    private func minY() -> Double{
        return graphs.map({ (g) -> Double in
            g.min
        }).min() ?? 0.0
    }

    
    private func createLabel(value: String, origin: CGPoint, size: CGSize) -> UITextField {
        let label = UITextField(frame: CGRect(origin: origin, size: size))
        label.text = value
        label.textColor = .black
        label.font = UIFont(name: label.font!.fontName, size: Constants.labelFontSize)
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.borderStyle = .none
        return label
    }
 
    
    private func getDummyGraphs() -> [Graph]{

        if dummyTSBData.count == 0{
            createDummyData()
        }
        
        let tsbGraph = Graph(data: dummyTSBData, colour: .yellow)
        tsbGraph.fill = true
        
        return [tsbGraph, Graph(data: dummyCTLData, colour: .red), Graph(data: dummyATLData, colour: .green)]
    }

    private func createDummyData(){
        var dayTss: Double = 50
        var dayCTL: Double = 25.0
        var dayATL: Double = 15.0
        let ctlFactor: Double = exp(-1/42.0)
        let atlFactor: Double = exp(-1/7.0)
        for i in 1...90{
            let random = Double.random(in: 0..<1)
            let factor = random * random
            dayTss = 110 * factor
            if Int.random(in: 1...10)<3{
                dayTss = 0.9
            }
            let d = Calendar.current.date(byAdding: DateComponents(day:i), to: Date())!
            //            let d = Calendar.current.date(from: DateComponents(year:2019, month:6, day:i))!
            dayCTL = dayTss * (1 - ctlFactor) + dayCTL * ctlFactor
            dayATL = dayTss * (1 - atlFactor) + dayATL * atlFactor
            dummyCTLData.append((d, dayCTL))
            dummyATLData.append((d, dayATL))
            dummyTSBData.append((d, dayCTL - dayATL))
            
        }
    }
}
