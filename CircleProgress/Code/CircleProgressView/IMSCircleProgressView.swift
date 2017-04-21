//
//  DRCircleProgressView.swift
//  CircleProgress
//
//  Created by Denis Romashov on 23.09.15.
//  Copyright © 2015 InMotion Soft. All rights reserved.
//

import UIKit

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

public extension CABasicAnimation {
    static func createMoveAnimation(fromValue: CGFloat, toValue value: CGFloat, withDuration duration: TimeInterval) -> CABasicAnimation {
        let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
        endAnimation.fromValue = fromValue
        endAnimation.toValue = value
        endAnimation.isRemovedOnCompletion = false
        endAnimation.fillMode = kCAFillModeForwards
        endAnimation.duration = duration
        endAnimation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionLinear)
        return endAnimation
    }
}

public enum IMSCircleProgressPosition: Float {
    case top = -90.0
    case right = 0.0
    case left = 180.0
    case bottom = 90.0
}

@objc public protocol IMSCircleProgressViewDelegate: NSObjectProtocol {
    func circleProgressView(_ view: IMSCircleProgressView, didChangeProgress progress: CGFloat)
}


open class IMSCircleProgressView: UIView {
    
    let kDefaultInterval = 0.33
    let kMaxAngle: Float = 180.0;
    let kFullCircleAngle: Float = 360.0;
    var progressLayer: CAShapeLayer!
    var backgroundLayer: CAShapeLayer!
    
    open var animatedProgress: Bool = true
    open var delegate: IMSCircleProgressViewDelegate?
    
    open var progressClockwiseDirection: Bool = true {
        didSet {
            self.setupCircleViewLineWidth(self.lineWidth, radius: self.radius)
        }
    }
    
    open var progress: CGFloat = 0.0 {
        didSet {
            let finalProgress = self.endlessProgress(progress)
            if progressDuration > 0 && self.animatedProgress {
                
                let progressDif = abs(oldValue - progress)
                if progressDif > 0 {
                    let time: TimeInterval = TimeInterval(progressDuration * progressDif)
                    let endAnimation = CABasicAnimation.createMoveAnimation(fromValue: oldValue, toValue: finalProgress, withDuration: time)
                    
                    self.progressLayer.add(endAnimation, forKey: "progress_layer_stroke")
                }
            } else {
                self.progressLayer.strokeEnd = finalProgress
            }
            
            self.delegate?.circleProgressView(self, didChangeProgress: self.progress)
        }
    }
    
    open var progressStrokeColor = UIColor.white {
        didSet {
            self.setupCircleViewLineWidth(self.lineWidth, radius: self.radius)
        }
    }
    
    open var progressStrokeWithRoundCorner = false {
        didSet {
            self.setupCircleViewLineWidth(self.lineWidth, radius: self.radius)
        }
    }
    
    open var progressBackgroundColor = UIColor.gray {
        didSet {
            self.setupCircleViewLineWidth(self.lineWidth, radius: self.radius)
        }
    }
    
    open var progressDuration : CGFloat = 3;
    
    open var radius: CGFloat = 0.0 {
        didSet {
            self.setupCircleViewLineWidth(self.lineWidth, radius: self.radius)
        }
    }
    
    open var lineWidth: CGFloat = 22.0 {
        didSet {
            self.setupCircleViewLineWidth(self.lineWidth, radius: self.radius)
        }
    }
    
    open var startAngle: Float = IMSCircleProgressPosition.top.rawValue {
        didSet {
            self.endAngle = kFullCircleAngle + self.startAngle
            self.setupCircleViewLineWidth(self.lineWidth, radius: self.radius)
        }
    }
    
    open var endAngle: Float = 0 {
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
        self.init(frame: frame, radius: frame.midX, width: 5)
    }
    
    convenience init(frame:CGRect, radius:CGFloat, width: CGFloat) {
        self.init(frame: frame, radius: radius, width: width, startAngle: IMSCircleProgressPosition.top.rawValue)
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
    func setupCircleViewLineWidth(_ lineWidth: CGFloat, radius circleRadius: CGFloat) {
        let circlePath = self.pathForRadius(circleRadius)
        
        if self.progressLayer == nil {
            self.backgroundLayer = CAShapeLayer()
            self.backgroundLayer.fillColor = UIColor.clear.cgColor
            self.backgroundLayer.strokeStart = 0
            self.backgroundLayer.strokeEnd = 1
            self.layer.addSublayer(self.backgroundLayer)
            
            self.progressLayer = CAShapeLayer()
            self.progressLayer.fillColor = UIColor.clear.cgColor
            self.layer.addSublayer(self.progressLayer)
        }
        
        let progressCircle = self.progressLayer
        progressCircle?.path = circlePath.cgPath
        progressCircle?.strokeColor = progressStrokeColor.cgColor
        progressCircle?.lineWidth = lineWidth
        progressCircle?.strokeEnd = self.progress
        
        if self.progressStrokeWithRoundCorner {
            progressCircle?.lineCap = kCALineCapRound
        } else {
            progressCircle?.lineCap = kCALineCapButt
        }
        
        self.backgroundLayer.path = progressCircle?.path
        self.backgroundLayer.strokeColor = self.progressBackgroundColor.cgColor
        self.backgroundLayer.lineWidth = lineWidth
    }
    
    func pathForRadius(_ radius: CGFloat) -> UIBezierPath {
        
        let centerPoint = CGPoint (x: self.frame.width / 2, y: self.frame.width / 2);
        let start = startAngle * Float.pi / 180.0
        let end = endAngle * Float.pi / 180.0
        var path = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: CGFloat(start), endAngle: CGFloat(end), clockwise: true)
        
        if self.progressClockwiseDirection == false {
            path = path.reversing()
        }
        
        return path
    }
    
    
    //    MARK: Helpers
    func endlessProgress(_ progress: CGFloat) -> CGFloat {
        let finalProgress =  min(1.0, progress)
        return max(0, finalProgress)
    }
}

