//
//  DRCircleProgressView.swift
//  CircleProgress
//
//  Created by Denis Romashov on 23.09.15.
//  Copyright © 2015 InMotion Soft. All rights reserved.
//

import UIKit

extension CABasicAnimation {
    static func createMoveAnimation(toValue value: CGFloat, withDuration duration: NSTimeInterval) -> CABasicAnimation {
        let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
        endAnimation.toValue = value
        endAnimation.removedOnCompletion = false
        endAnimation.fillMode = kCAFillModeForwards
        endAnimation.duration = duration
        return endAnimation
    }
}


enum IMSCircleProgressPosition: Float {
    case Top = -90.0
    case Right = 0.0
    case Left = 180.0
    case Bottom = 90.0
}


class IMSCircleProgressView: UIView {

    let kDefaultInterval = 0.33
    let kMaxAngle: Float = 180.0;
    let kFullCircleAngle: Float = 360.0;
    
    var currentProgress: CGFloat = 0.0
    var progressFillColor = UIColor.clearColor()
    var progressStrokeColor = UIColor.darkGrayColor()
    var progressTimeInterval : CGFloat = 10;
    
    internal var radius: CGFloat = 0.0
    internal var lineWidth: CGFloat = 22.0
    internal var startAngle: Float!
    internal var endAngle: Float!
    
    override class func layerClass() -> AnyClass {
        return CAShapeLayer.self
    }
    
    
// MARK: Public Methods
    func initProgressViewWithRadius(radius: CGFloat, lineWidth width: CGFloat) {
        self.startAngle = IMSCircleProgressPosition.Top.rawValue
        self.endAngle = kFullCircleAngle + self.startAngle
        self.lineWidth = width
        self.radius = radius
        self.setupCircleViewLineWidth(self.lineWidth, radius: radius)
    }

    func initProgressView(withRadius radius: CGFloat, lineWidth width: CGFloat, startAngle angle: Float) {
        self.initProgressViewWithRadius(radius, lineWidth: width)
        self.startAngle = angle
        self.endAngle = kFullCircleAngle + angle
    }
    
    func setProgress(progress: CGFloat) {
        currentProgress = progress
        
        let finalProgress = self.endlessProgress(progress)
        let time: NSTimeInterval = NSTimeInterval((progressTimeInterval/10) * finalProgress)
        let endAnimation = CABasicAnimation.createMoveAnimation(toValue: finalProgress, withDuration: time)
        
        self.layer.addAnimation(endAnimation, forKey: nil)
    }
    
    
// MARK: Private Methods
    private func setupCircleViewLineWidth(lineWidth: CGFloat, radius circleRadius: CGFloat) {
        
        let circlePath = self.setupPathWithRadius(circleRadius)
        
        let progressCircle = self.layer as! CAShapeLayer
        progressCircle.path = circlePath.CGPath
        progressCircle.strokeColor = progressStrokeColor.CGColor
        progressCircle.fillColor = progressFillColor.CGColor
        progressCircle.lineWidth = lineWidth
        progressCircle.strokeStart = 0
        progressCircle.strokeEnd = 0
    }
    
    func setupPathWithRadius(radius: CGFloat) -> UIBezierPath {
        
        let centerPoint = CGPoint (x: self.frame.width / 2, y: self.frame.width / 2);
        let start = startAngle * Float(M_PI)/180.0
        let end = endAngle * Float(M_PI)/180.0
        return UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: CGFloat(start), endAngle: CGFloat(end), clockwise: true);
    }    
    
//    MARK: Helpers
    private func endlessProgress(progress: CGFloat) -> CGFloat {
        let finalProgress =  min(1.0, progress)
        return max(0, finalProgress)
    }
}

