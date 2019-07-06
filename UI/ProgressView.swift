//
//  ProgressView.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 03/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit
import Foundation

class ProgressView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    private var progressPath: UIBezierPath!
    private var secondaryProgressPath: UIBezierPath!
    private var secondaryProgressShapeLayer: CAShapeLayer!
    private var progressShapeLayer: CAShapeLayer!
    private var progressLayer: CAShapeLayer!
    private var secondaryProgressLayer: CAShapeLayer!
    private let thickness: CGFloat = 24.0
    
//    var progressBackgroundColour: CGColor = UIColor.purple.cgColor
    var progressColour: UIColor = UIColor.green
    var secondaryProgressColour: UIColor = UIColor.red
    
    var progress: Float = 0 {
        willSet(newValue){
            progressLayer.strokeEnd = CGFloat(newValue)
        }
    }

    var secondaryProgress: Float = 0 {
        willSet(newValue){
            secondaryProgressLayer.strokeEnd = CGFloat(newValue)
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        progressPath = UIBezierPath()
        secondaryProgressPath = UIBezierPath()
        self.createCircle()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        progressPath = UIBezierPath()
        secondaryProgressPath = UIBezierPath()
        self.createCircle()
    }
    
    func createCircle(){
        createCirclePath()
        progressShapeLayer = CAShapeLayer()
        progressShapeLayer.path = progressPath.cgPath
        progressShapeLayer.lineWidth = thickness / 2
        progressShapeLayer.fillColor = nil
        progressShapeLayer.strokeColor = progressColour.withAlphaComponent(0.25).cgColor
        
        secondaryProgressShapeLayer = CAShapeLayer()
        secondaryProgressShapeLayer.path = secondaryProgressPath.cgPath
        secondaryProgressShapeLayer.lineWidth = thickness / 2
        secondaryProgressShapeLayer.fillColor = nil
        secondaryProgressShapeLayer.strokeColor = secondaryProgressColour.withAlphaComponent(0.25).cgColor

        progressLayer = CAShapeLayer()
        progressLayer.path = progressPath.cgPath
        progressLayer.lineCap = .round
        progressLayer.lineWidth = thickness / 2
        progressLayer.fillColor = nil
        progressLayer.strokeColor = progressColour.cgColor
        progressLayer.strokeEnd = 0.0

        secondaryProgressLayer = CAShapeLayer()
        secondaryProgressLayer.path = secondaryProgressPath.cgPath
        secondaryProgressLayer.lineCap = .round
        secondaryProgressLayer.lineWidth = thickness / 2
        secondaryProgressLayer.fillColor = nil
        secondaryProgressLayer.strokeColor = secondaryProgressColour.cgColor
        secondaryProgressLayer.strokeEnd = 0.0
        
        self.layer.addSublayer(progressShapeLayer)
        self.layer.addSublayer(secondaryProgressShapeLayer)
        self.layer.addSublayer(progressLayer)
        self.layer.addSublayer(secondaryProgressLayer)
    }
    
    private func createCirclePath(){
        let x = self.frame.width/2
        let y = self.frame.height/2
//        let centre = self.center
        let centre = CGPoint(x: x, y: y)
        let progressRadius = min(x,y) - thickness / 2.0
        let secondaryProgressRadius = min(x,y) - thickness
        progressPath.addArc(withCenter: centre, radius: progressRadius, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi * 1.5 , clockwise: true)
        secondaryProgressPath.addArc(withCenter: centre, radius: secondaryProgressRadius, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi * 1.5 , clockwise: true)
        progressPath.close()
        secondaryProgressPath.close()
        print("Frame: \(frame)")
        print("Superview Frame: \(super.frame)")
        print("Centre: \(centre)")
        print("Radii: \(secondaryProgressRadius) and \(progressRadius)")
    }
    
}
