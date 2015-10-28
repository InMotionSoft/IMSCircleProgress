//
//  DRCircleProgressView.swift
//  CircleProgress
//
//  Created by Denis Romashov on 23.09.15.
//  Copyright © 2015 InMotion Soft. All rights reserved.
//

import UIKit

public extension CABasicAnimation {
    static func createMoveAnimation(toValue value: CGFloat, withDuration duration: NSTimeInterval) -> CABasicAnimation {
        let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
        endAnimation.toValue = value
        endAnimation.removedOnCompletion = false
        endAnimation.fillMode = kCAFillModeForwards
        endAnimation.duration = duration
        return endAnimation
    }
}


public enum IMSCircleProgressPosition: Float {
    case Top = -90.0
    case Right = 0.0
    case Left = 180.0
    case Bottom = 90.0
}


public class IMSCircleProgressView: UIView {
    
    let kDefaultInterval = 0.33
    let kMaxAngle: Float = 180.0;
    let kFullCircleAngle: Float = 360.0;
    var progressLayer: CAShapeLayer!
    var backgroundLayer: CAShapeLayer!
    
    public var progress: CGFloat = 0.0 {
        didSet {
            let finalProgress = self.endlessProgress(progress)
            if progressDuration > 0 {
            
                let progressDif = abs(oldValue - progress)
                if progressDif > 0 {
                    let time: NSTimeInterval = NSTimeInterval(progressDuration * progressDif)
                    let endAnimation = CABasicAnimation.createMoveAnimation(toValue: finalProgress, withDuration: time)
                    
                    self.progressLayer.addAnimation(endAnimation, forKey: nil)
                }
            } else {
                self.progressLayer.strokeEnd = finalProgress
            }
        }
    }
    
    public var progressStrokeColor = UIColor.whiteColor() {
        didSet {
            self.setupCircleViewLineWidth(self.lineWidth, radius: self.radius)
        }
    }
    
    public var progressBackgroundColor = UIColor.grayColor() {
        didSet {
            self.setupCircleViewLineWidth(self.lineWidth, radius: self.radius)
        }
    }
    
    public var progressDuration : CGFloat = 3;
    
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
    
    public var startAngle: Float = IMSCircleProgressPosition.Top.rawValue {
        didSet {
            self.endAngle = kFullCircleAngle + self.startAngle
            self.setupCircleViewLineWidth(self.lineWidth, radius: self.radius)
        }
    }
    
    public var endAngle: Float = 0 {
        didSet {
            self.setupCircleViewLineWidth(self.lineWidth, radius: self.radius)
        }
    }
    
    
    // MARK: Public Methods
    required public init?(coder aDecoder: NSCoder) {
        self.endAngle = kFullCircleAngle + self.startAngle
        
        super.init(coder: aDecoder)
        
        self.radius = self.frame.width / 2
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
    func setupCircleViewLineWidth(lineWidth: CGFloat, radius circleRadius: CGFloat) {
        let circlePath = self.pathForRadius(circleRadius)
        
        if self.progressLayer == nil {
            self.backgroundLayer = CAShapeLayer()
            self.backgroundLayer.fillColor = UIColor.clearColor().CGColor
            self.backgroundLayer.strokeStart = 0
            self.backgroundLayer.strokeEnd = 1
            self.layer.addSublayer(self.backgroundLayer)
            
            self.progressLayer = CAShapeLayer()
            self.progressLayer.fillColor = UIColor.clearColor().CGColor
            self.layer.addSublayer(self.progressLayer)
        }
        
        let progressCircle = self.progressLayer
        progressCircle.path = circlePath.CGPath
        progressCircle.strokeColor = progressStrokeColor.CGColor
        progressCircle.lineWidth = lineWidth
        progressCircle.strokeEnd = self.progress
        
        self.backgroundLayer.path = progressCircle.path
        self.backgroundLayer.strokeColor = self.progressBackgroundColor.CGColor
        self.backgroundLayer.lineWidth = lineWidth
    }
    
    func pathForRadius(radius: CGFloat) -> UIBezierPath {
        
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

