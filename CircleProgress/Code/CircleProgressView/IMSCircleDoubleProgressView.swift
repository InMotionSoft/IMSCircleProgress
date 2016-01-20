//
//  IMSCircleDoubleProgressView.swift
//  CircleProgress
//
//  Created by Max on 20.01.16.
//  Copyright © 2016 InMotion Soft. All rights reserved.
//

import Foundation
import UIKit


@objc public protocol IMSCircleDoubleProgressViewDelegate: NSObjectProtocol {
    func circleDoubleProgressView(view: IMSCircleProgressView, didChangeSecondProgress progress: CGFloat)
}


@objc public class IMSCircleDoubleProgressView: IMSCircleDragProgressView {
 
    var secondProgressLayer: CAShapeLayer!
    public var secondProgressDelegate: IMSCircleDoubleProgressViewDelegate?
    var currentProgressIsSecond: Bool = false
    
    public var secondProgressStrokeColor = UIColor.whiteColor() {
        didSet {
            self.setupCircleViewLineWidth(self.lineWidth, radius: self.radius)
        }
    }
    
    public var firstProgress: CGFloat {
        get {
            return self.progress
        }
        
        set {
            self.progress = newValue
        }
    }
    
    private var currentProgress: CGFloat {
        get {
            return (self.currentProgressIsSecond) ? self.secondProgress : self.firstProgress
        }
    }
    
    public var secondProgress: CGFloat = 0.0 {
        didSet {
            let finalProgress = self.endlessProgress(secondProgress)
            if progressDuration > 0 && self.animatedProgress {
                
                let progressDif = abs(oldValue - secondProgress)
                if progressDif > 0 {
                    let time: NSTimeInterval = NSTimeInterval(progressDuration * progressDif)
                    let endAnimation = CABasicAnimation.createMoveAnimation(toValue: finalProgress, withDuration: time)
                    
                    self.secondProgressLayer.addAnimation(endAnimation, forKey: nil)
                }
            } else {
                self.secondProgressLayer.strokeEnd = finalProgress
            }
            
            self.secondProgressDelegate?.circleDoubleProgressView(self, didChangeSecondProgress: secondProgress)
        }
    }
    
    override func setupCircleViewLineWidth(lineWidth: CGFloat, radius circleRadius: CGFloat) {
        super.setupCircleViewLineWidth(lineWidth, radius: radius)
        
        let circlePath = self.pathForRadius(circleRadius)
        
        if self.secondProgressLayer == nil {
            self.secondProgressLayer = CAShapeLayer()
            self.secondProgressLayer.fillColor = UIColor.clearColor().CGColor
            self.layer.addSublayer(self.secondProgressLayer)
        }
        
        self.secondProgressLayer.path = circlePath.CGPath
        self.secondProgressLayer.strokeColor = self.secondProgressStrokeColor.CGColor
        self.secondProgressLayer.lineWidth = lineWidth
        self.secondProgressLayer.strokeEnd = self.secondProgress
        
        let layer = self.secondProgressLayer
        layer.removeAllAnimations()
    }
    
    func progressForAngle(angle: Float, currentProgress: Float) -> Float {
        let angleForProgress = angle - self.startAngle
        
        let fullCircleAngle = fabsf(self.startAngle) + fabsf(self.endAngle);
        var progress = angleForProgress / fullCircleAngle
        
        if progress < 0 && currentProgress > 0.5 {
            progress = (kFullCircleAngle + angleForProgress)/fullCircleAngle
        }
        
        progress = min(Float(1), Float(progress))
        progress = max(Float(0), Float(progress))
        
        return progress
    }
    
    
    //    MARK: Events
    override func buttonDrag(button: UIButton, withEvent event:UIEvent) {
        
        guard let touch: UITouch = event.allTouches()?.first else {
            return
        }
        
        let previousLocation = touch.previousLocationInView(button)
        let location = touch.locationInView(button)
        let deltaX: CGFloat = location.x - previousLocation.x
        let deltaY: CGFloat = location.y - previousLocation.y
        
        var newButtonCenter = CGPointMake(button.center.x + deltaX, button.center.y + deltaY)
        var angle: Float = self.angleBetweenCenterAndPoint(newButtonCenter)
        newButtonCenter = self.pointForAngle(angle)
        
        if self.progressClockwiseDirection == false {
            if angle < 0 && self.progress < 0.5 {
                angle += kFullCircleAngle
            }
        }
        
        let fullAngle = fabsf(self.startAngle) + fabsf(self.endAngle)
        if fullAngle != kFullCircleAngle {
            if ((startAngle > 0 && angle > startAngle) || (startAngle < 0 && angle < startAngle)) {
                angle = self.startAngle
                newButtonCenter = self.pointForAngle(angle)
            } else if ((endAngle > 0 && angle > endAngle) || (endAngle < 0 && angle < endAngle)) {
                angle = self.endAngle
                newButtonCenter = self.pointForAngle(angle)
            }
        }
        
        var progress = self.progressForAngle(angle, currentProgress: Float(self.currentProgress))
        
        if self.progressClockwiseDirection == false && progress <= 1 {
            progress = 1 - progress
        }
        
        if CGFloat(progress) == self.progress {
            if self.shouldCrossStartPosition == false {
                return
            } else {
                if progress > 0.5 {
                    progress = 0
                    if fullAngle != kFullCircleAngle {
                        newButtonCenter = self.pointForAngle(self.startAngle)
                    }
                } else {
                    progress = 1
                    if fullAngle != kFullCircleAngle {
                        newButtonCenter = self.pointForAngle(self.endAngle)
                    }
                }
            }
        }
        
        button.center = newButtonCenter
        
        if progress >= 0 && progress < 0.1 {
            if self.currentProgressIsSecond == false {
                if self.firstProgress >= 0.9 {
                    self.firstProgress = 1
                    self.currentProgressIsSecond = true
                }
            } else if self.firstProgress == 1 && self.secondProgress >= 0.9 {
                    self.currentProgressIsSecond = false
                    self.firstProgress = 0
                    self.secondProgress = 0
            }
        }
        
        if self.currentProgressIsSecond {
            self.secondProgress = CGFloat(progress)
        } else {
            self.firstProgress = CGFloat(progress)
        }
    }
}