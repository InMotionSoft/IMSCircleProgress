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


public class IMSCircleProgressView: UIView {

    let kDefaultInterval = 0.33
    let kMaxAngle: Float = 180.0;
    let kFullCircleAngle: Float = 360.0;
    
    public var progress: CGFloat = 0.0 {
        didSet {
            let finalProgress = self.endlessProgress(progress)
            let progressDif = abs(oldValue - progress)
            let time: NSTimeInterval = NSTimeInterval(progressDuration * progressDif)
            let endAnimation = CABasicAnimation.createMoveAnimation(toValue: finalProgress, withDuration: time)

            self.layer.addAnimation(endAnimation, forKey: nil)
        }
    }
    
    public var progressFillColor = UIColor.redColor()
    public var progressStrokeColor = UIColor.darkGrayColor() {
        didSet {
            self.setupCircleViewLineWidth(self.lineWidth, radius: self.radius)
        }
    }
    
    public var progressDuration : CGFloat = 10;
    
    public var radius: CGFloat = 0.0 {
        didSet {
            self.setupCircleViewLineWidth(self.lineWidth, radius: self.radius)
        }
    }
    
    public var lineWidth: CGFloat = 22.0 {
        didSet {
            self.setupCircleViewLineWidth(self.lineWidth, radius: self.radius)
        }
    }
    
    public var startAngle: Float = IMSCircleProgressPosition.Top.rawValue
    public var endAngle: Float = 0
    
    
    override public class func layerClass() -> AnyClass {
        return CAShapeLayer.self
    }
    
    
// MARK: Public Methods
    required public init?(coder aDecoder: NSCoder) {
        self.endAngle = kFullCircleAngle + self.startAngle
        
        super.init(coder: aDecoder)
        
        self.setupCircleViewLineWidth(self.lineWidth, radius: radius)
    }
    
    override convenience init(frame: CGRect) {
        self.init(frame: frame, radius: CGRectGetMidX(frame), width: 5)
    }
    
    convenience init(frame:CGRect, radius:CGFloat, width: CGFloat) {
        self.init(frame: frame, radius: radius, width: width, startAngle: IMSCircleProgressPosition.Top.rawValue)
    }

    init (frame:CGRect, radius:CGFloat, width: CGFloat, startAngle: Float) {
        self.startAngle = startAngle
        self.endAngle = kFullCircleAngle + self.startAngle
        self.lineWidth = width
        self.radius = radius

        super.init(frame: frame)
        
        self.setupCircleViewLineWidth(self.lineWidth, radius: radius)
    }
    
    
// MARK: Private Methods
    private func setupCircleViewLineWidth(lineWidth: CGFloat, radius circleRadius: CGFloat) {
        let circlePath = self.setupPathWithRadius(circleRadius)
        
        let progressCircle = self.layer as! CAShapeLayer
        progressCircle.path = circlePath.CGPath
        progressCircle.strokeColor = progressStrokeColor.CGColor
        progressCircle.fillColor = progressFillColor.CGColor
        progressCircle.lineWidth = lineWidth
        progressCircle.strokeEnd = self.progress
    }
    
    func setupPathWithRadius(radius: CGFloat) -> UIBezierPath {
        
        let centerPoint = CGPoint (x: self.frame.width / 2, y: self.frame.width / 2);
        let start = startAngle * Float(M_PI) / 180.0
        let end = endAngle * Float(M_PI) / 180.0
        return UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: CGFloat(start), endAngle: CGFloat(end), clockwise: true);
    }    
    
//    MARK: Helpers
    private func endlessProgress(progress: CGFloat) -> CGFloat {
        let finalProgress =  min(1.0, progress)
        return max(0, finalProgress)
    }
}

