//
//  GraphView.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 25/06/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit



// TO DO - this class assumes the x axis points are equal distance apart. eg assumes we have y data for all days. Need to plot correctly even if days are missing
// TO DO - ensure doesn't throw exception if not enough data points. Check if data has just one point
@IBDesignable class GraphView: UIView {

    private struct Constants {
        static let margin: CGFloat = 20.0
        static let topBorder: CGFloat = 20.0
        static let bottomBorder: CGFloat = 30.0
        static let colorAlpha: CGFloat = 0.3
        static let circleDiameter: CGFloat = 5.0
        static let labelFontSize: CGFloat = 12.0
        static let pointSize: CGFloat = 5.0
    }

    // colours for gradient.
    var startColour: UIColor = MAIN_BLUE
    var endColour: UIColor = .white
    
    private var colors: [CGColor]!
    private var colorSpace:CGColorSpace!
    private var colorLocations: [CGFloat]!
    private var gradient: CGGradient!
    
    private var graphs: [Graph] = []
    private var labels: [UITextField] = []
    
    //    dummy data
    var dummyCTLData: [(Date, Double)] = []
    var dummyATLData: [(Date, Double)] = []
    var dummyTSBData: [(Date, Double)] = []
    var dummyTSSData: [(Date, Double)] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        colors = [startColour.cgColor, endColour.cgColor]
        colorSpace = CGColorSpaceCreateDeviceRGB()
        colorLocations = [0.0, 1.0]
        gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)!
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
        
        if graphs.count == 0{ graphs = getDummyGraphs() }
        
        let context = UIGraphicsGetCurrentContext()!

        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: self.bounds.height)
        // draw background
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        
        for graph in graphs{
            if graph.data.count > 0{
                if let g = graph as? LineGraph{
                    addGraph(rect, graph: g)
                }else if let g = graph as? PointGraph{
                    addGraph(rect, graph: g)
                }
            }
        }
        
        addHorizontalLines(rect)
    }
    
    fileprivate func addHorizontalLines(_ rect: CGRect){
        //remove old labels
        for l in labels{
            l.removeFromSuperview()
        }
        labels = []
        
        let minimum = minY()
        let max = maxY()
        let middle = (minimum<0.0) ? (max / 2.0) : ((max-minimum)/2.0)
   
        // max
        addHorizontalLine(atY: max, inRect: rect, withColour: endColour)
        // middle
        addHorizontalLine(atY: middle, inRect: rect, withColour: endColour)
        //min
        addHorizontalLine(atY: minimum, inRect: rect, withColour: startColour)
        // zero of needed
        if minimum < 0.0{
            addHorizontalLine(atY: 0.0, inRect: rect, withColour: .black)
        }
    }
    
    private func addHorizontalLine(atY y: Double, inRect rect: CGRect, withColour colour: UIColor){
        let line = UIBezierPath()
        let coordinates = getCoordinateFunction(rect)
        let yCoord: CGFloat = coordinates((Date(), y)).y
        line.move(to: CGPoint(x: Constants.margin, y: yCoord))
        line.addLine(to: CGPoint(x: rect.width - Constants.margin, y: yCoord))
        let maxLabel = createLabel(value: String(Int(y)), origin: CGPoint(x: 0.0, y: yCoord - Constants.margin/2.0), size: CGSize(width: Constants.margin*2, height: Constants.margin))
        addSubview(maxLabel)
        labels.append(maxLabel)
        colour.setStroke()
        line.lineWidth = 1.0
        line.stroke()
    }
    
    private func getCoordinateFunction(_ rect: CGRect) -> ((Date, Double)) -> CGPoint{
        let width = rect.width
        let height = rect.height
        let margin = Constants.margin
        let topBorder: CGFloat = Constants.topBorder
        let bottomBorder: CGFloat = Constants.bottomBorder
        let graphHeight = height - topBorder - bottomBorder
        let maxValue = maxY()
        let minValue = minY()
        let (from:minDate, to:maxDate) = graphDateRange()
        let xRange = maxDate.timeIntervalSince(minDate)
        let yRange = max(0.1, CGFloat(maxValue - minValue))

        let f = { (item: (date: Date, value: Double)) -> CGPoint in
            let spacer = (width - margin * 2 - 4) / CGFloat(xRange)
            var x: CGFloat = CGFloat(item.date.timeIntervalSince(minDate)) * spacer
            x += margin + 2
            var y:CGFloat = CGFloat(item.value - minValue) / yRange * graphHeight
            y = graphHeight + topBorder - y // Flip the graph
            return CGPoint(x:x,y:y)
        }
    
        
        return f
    }
    
    private func graphDateRange() -> (from: Date, to: Date){
        if graphs.count == 0{
            return (Date(), Date())
        }
        let minD: Date = graphs.reduce(graphs[0].minDate, {min($0, $1.minDate)})
        let maxD: Date = graphs.reduce(graphs[0].maxDate, {max($0, $1.maxDate)})
        return (minD, maxD)
    }
    

    fileprivate func addGraph(_ rect: CGRect, graph: LineGraph) {
    
        if graph.data.count == 0{
            return
        }
        
        // draw the line graph
        graph.colour.setFill()
        graph.colour.setStroke()
        

        //draw lines
        let graphPath = UIBezierPath()
        // this is function to convert a time series point in to the co-ordinates in our graph within the given rect
        let coordinates = getCoordinateFunction(rect)
        //go to start of line
        graphPath.move(to: coordinates(graph.data[0]))

        //add points for each item in the graphPoints array
        for d in graph.data {
            let nextPoint = coordinates(d)
            graphPath.addLine(to: nextPoint)
        }
        
        //draw the line on top of the clipped gradient
        graphPath.lineWidth = 2.0
        graphPath.stroke()
        
        if graph.fill{
            UIGraphicsGetCurrentContext()?.saveGState()
            let cPath = graphPath.copy() as! UIBezierPath
            let (from:minDate, to:maxDate) = graphDateRange()
            cPath.addLine(to: coordinates((maxDate, 0.0)))
            cPath.addLine(to: coordinates((minDate, 0.0)))
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
                let y0 = coordinates((Date(), 0)).y
                let yMax = coordinates((Date(), graph.max)).y
                let yMin = coordinates((Date(), graph.min)).y
                colourLocations = [0.0, (y0-yMax)/(yMin-yMax) , 1.0]
            }
            if let gradient = CGGradient(colorsSpace: colourSpace,
                                         colors: colours as CFArray,
                                         locations: colourLocations){
                let context = UIGraphicsGetCurrentContext()!
                let max = (graph.max < 0) ? 0.0 : graph.max
                let yMax = coordinates((Date(), max)).y
                let yMin = coordinates((Date(), graph.min)).y
                context.drawLinearGradient(gradient, start: CGPoint(x: Constants.margin, y: yMax), end: CGPoint(x: Constants.margin, y: yMin), options: [])
            }
            UIGraphicsGetCurrentContext()?.restoreGState()
        }
    }
    
    fileprivate func addGraph(_ rect: CGRect, graph: PointGraph) {
        
        let coordinates = getCoordinateFunction(rect)
        graph.colour.setFill()
        graph.colour.setStroke()
        
        // draw points
        for d in graph.data{
            let p = coordinates(d)
            let path = UIBezierPath(ovalIn: CGRect(x: p.x - graph.pointSize/2, y: p.y - graph.pointSize/2, width: graph.pointSize, height: graph.pointSize))

            if graph.fill{
                UIColor.white.setFill()
                UIColor.white.setStroke()
                path.fill()
            }
            graph.colour.setFill()
            graph.colour.setStroke()
            path.stroke()
        }
    }

    
    
    private func maxY() -> Double{
        return graphs.map({$0.max}).max() ?? 0.0
    }
    
    private func minY() -> Double{
        return graphs.map({$0.min}).min() ?? 0.0
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
        
        let tsbGraph = LineGraph(data: dummyTSBData, colour: .yellow)
        tsbGraph.fill = true
        let tssGraph = PointGraph(data: dummyTSSData, colour: .black)
        tssGraph.point = true
        return [tsbGraph, LineGraph(data: dummyCTLData, colour: .red), LineGraph(data: dummyATLData, colour: .green), tssGraph]
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
            dayCTL = dayTss * (1 - ctlFactor) + dayCTL * ctlFactor
            dayATL = dayTss * (1 - atlFactor) + dayATL * atlFactor
            dummyCTLData.append((d, dayCTL))
            dummyATLData.append((d, dayATL))
            dummyTSBData.append((d, dayCTL - dayATL))
            dummyTSSData.append((d, dayTss))
            
        }
    }
}
