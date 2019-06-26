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

@IBDesignable class GraphView: UIView {

    private struct Constants {
        static let cornerRadiusSize = CGSize(width: 8.0, height: 8.0)
        static let margin: CGFloat = 20.0
        static let topBorder: CGFloat = 60
        static let bottomBorder: CGFloat = 50
        static let colorAlpha: CGFloat = 0.3
        static let circleDiameter: CGFloat = 5.0
    }

    // colours for gradient.
    @IBInspectable var startColour: UIColor = .red
    @IBInspectable var endColor: UIColor = .green
    
    var graphs: [Graph] = []
    
    
    override func draw(_ rect: CGRect) {
        
        //temp
        graphs = createDummyData()
        
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: UIRectCorner.allCorners,
                                cornerRadii: Constants.cornerRadiusSize)
        path.addClip()
        
        let context = UIGraphicsGetCurrentContext()!
        let colors = [startColour.cgColor, endColor.cgColor]
        
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


    }

    fileprivate func addGraph(_ rect: CGRect, graph: Graph) {
        
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
        // again this is a function
        let columnYPoint = { (graphPoint:Double) -> CGFloat in
            var y:CGFloat = CGFloat(graphPoint - minValue) / CGFloat(maxValue - minValue) * graphHeight
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

            
            var colours = [startColour.cgColor, endColor.cgColor]
            var colourLocations: [CGFloat] = [0.0, 1.0]
            let colourSpace = CGColorSpaceCreateDeviceRGB()
            if graph.min < 0{
                colours = [startColour.cgColor, endColor.cgColor, startColour.cgColor]
                colourLocations = [0.0, (columnYPoint(0)-columnYPoint(graph.max))/(columnYPoint(graph.min)-columnYPoint(graph.max)) , 1.0]
                print(colourLocations)
            }
            if let gradient = CGGradient(colorsSpace: colourSpace,
                                         colors: colours as CFArray,
                                         locations: colourLocations){
                let context = UIGraphicsGetCurrentContext()!
                context.drawLinearGradient(gradient, start: CGPoint(x: margin, y: columnYPoint(graph.max)), end: CGPoint(x: margin, y: columnYPoint(graph.min)), options: [])

            }
            UIGraphicsGetCurrentContext()?.restoreGState()
        }
        
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
    
    private func createDummyData() -> [Graph]{
        //    dummy data
        var ctlData: [(Date, Double)] = []
        var atlData: [(Date, Double)] = []
        var tsbData: [(Date, Double)] = []
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
            ctlData.append((d, dayCTL))
            atlData.append((d, dayATL))
            tsbData.append((d, dayCTL - dayATL))
            
        }
        
        let tsbGraph = Graph(data: tsbData, colour: .yellow)
        tsbGraph.fill = true
        
        return [tsbGraph, Graph(data: ctlData, colour: .red), Graph(data: atlData, colour: .green)]
    }
    
}
