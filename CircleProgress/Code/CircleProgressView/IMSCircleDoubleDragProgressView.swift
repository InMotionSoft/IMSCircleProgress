//
//  IMSCircleDoubleProgressView.swift
//  CircleProgress
//
//  Created by Max on 20.01.16.
//  Copyright © 2016 InMotion Soft. All rights reserved.
//

import Foundation
import UIKit


@objc public protocol IMSCircleDoubleDragProgressViewDelegate: NSObjectProtocol {
    func circleDoubleProgressView(_ view: IMSCircleProgressView, didChangeSecondProgress progress: CGFloat)
}


@objc open class IMSCircleDoubleDragProgressView: IMSCircleDragProgressView {
    
    var secondProgressLayer: CAShapeLayer!
    open var secondProgressDelegate: IMSCircleDoubleDragProgressViewDelegate?
    fileprivate var currentProgressIsSecond: Bool = false
    
    open var secondProgressStrokeColor = UIColor.white {
        didSet {
            self.setupCircleViewLineWidth(self.lineWidth, radius: self.radius)
        }
    }
    
    open var firstProgress: CGFloat {
        get {
            return self.progress
        }
        
        set {
            self.progress = newValue
        }
    }
    
    var currentProgress: CGFloat {
        get {
            return (self.currentProgressIsSecond) ? self.secondProgress : self.firstProgress
        }
    }
    
    open var secondProgress: CGFloat = 0.0 {
        willSet {
            if secondProgress == 0 {
                let startAngle = (self.progressClockwiseDirection) ? self.startAngle : self.endAngle
                let anglePoint = self.pointForAngle(startAngle)
                let startPoint = CGPoint(x: CGFloat(NSInteger(anglePoint.x)), y: CGFloat(NSInteger(anglePoint.y)))
                let buttonPoint = CGPoint(x: CGFloat(NSInteger(self.progressButton.center.x)), y: CGFloat(NSInteger(self.progressButton.center.y)))
                
                if startPoint.equalTo(buttonPoint) {
                    let angle: Float = self.angleForProgress(newValue)
                    self.progressButton.center = self.pointForAngle(angle)
                }
                self.currentProgressIsSecond = true
            }
        }
        
        didSet {
            let finalProgress = self.endlessProgress(secondProgress)
            if progressDuration > 0 && self.animatedProgress {
                
                let progressDif = abs(oldValue - secondProgress)
                if progressDif > 0 {
                    let time: TimeInterval = TimeInterval(progressDuration * progressDif)
                    let endAnimation = CABasicAnimation.createMoveAnimation(toValue: finalProgress, withDuration: time)
                    
                    self.secondProgressLayer.add(endAnimation, forKey: nil)
                }
            } else {
                self.secondProgressLayer.strokeEnd = finalProgress
                self.secondProgressLayer.removeAllAnimations()
            }
            
            self.secondProgressDelegate?.circleDoubleProgressView(self, didChangeSecondProgress: secondProgress)
        }
    }
    
    override func setupCircleViewLineWidth(_ lineWidth: CGFloat, radius circleRadius: CGFloat) {
        super.setupCircleViewLineWidth(lineWidth, radius: radius)
        
        let circlePath = self.pathForRadius(circleRadius)
        
        if self.secondProgressLayer == nil {
            self.secondProgressLayer = CAShapeLayer()
            self.secondProgressLayer.fillColor = UIColor.clear.cgColor
            self.layer.addSublayer(self.secondProgressLayer)
        }
        
        self.secondProgressLayer.path = circlePath.cgPath
        self.secondProgressLayer.strokeColor = self.secondProgressStrokeColor.cgColor
        self.secondProgressLayer.lineWidth = lineWidth
        self.secondProgressLayer.strokeEnd = self.secondProgress
        
        let layer = self.secondProgressLayer
        layer?.removeAllAnimations()
    }
    
    func progressForAngle(_ angle: Float, currentProgress: Float) -> Float {
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
    override func buttonDrag(_ button: UIButton, withEvent event:UIEvent) {
        
        guard let touch: UITouch = event.allTouches?.first else {
            return
        }
        
        let previousLocation = touch.previousLocation(in: button)
        let location = touch.location(in: button)
        let deltaX: CGFloat = location.x - previousLocation.x
        let deltaY: CGFloat = location.y - previousLocation.y
        
        var newButtonCenter = CGPoint(x: button.center.x + deltaX, y: button.center.y + deltaY)
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
                    self.firstProgress = 1
                    self.currentProgressIsSecond = true
                    
                    if fullAngle != kFullCircleAngle {
                        newButtonCenter = self.pointForAngle(self.endAngle)
                    }
                }
            }
        }
        
        if progress >= 0 && progress < 0.1 {
            if self.currentProgressIsSecond == false {
                if self.firstProgress >= 0.9 {
                    self.firstProgress = 1
                    self.currentProgressIsSecond = true
                }
            } else if self.firstProgress == 1 && self.secondProgress >= 0.9 {
                
                if self.shouldCrossStartPosition {
                    self.currentProgressIsSecond = false
                    self.firstProgress = 0
                    self.secondProgress = 0
                } else {
                    self.firstProgress = 1
                    self.secondProgress = 1
                    newButtonCenter = self.pointForAngle(self.endAngle)
                    button.center = newButtonCenter
                    return
                }
            } else if progress == 0 && self.currentProgressIsSecond {
                self.secondProgress = 0
                self.currentProgressIsSecond = false
                progress = 1
            }
        }
        
        button.center = newButtonCenter
        
        if self.currentProgressIsSecond {
            self.secondProgress = CGFloat(progress)
        } else {
            self.firstProgress = CGFloat(progress)
        }
    }
}
