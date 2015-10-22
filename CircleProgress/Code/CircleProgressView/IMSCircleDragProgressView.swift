//
//  DRCircleDragProgressView.swift
//  CircleProgress
//
//  Created by Denis Romashov on 24.09.15.
//  Copyright © 2015 InMotion Soft. All rights reserved.
//

import Foundation
import UIKit


public class IMSCircleDragProgressView: IMSCircleProgressView {
    
    public var shouldCrossStartPosition = false
    
    private(set) public var progressButton: UIButton!
    public var progressButtonSize: CGFloat = 44.0 {
        didSet {
            self.updateProgressButtonFrame()
        }
    }
    
    var strokeStart: CGFloat = 0.0
    override public var progress: CGFloat {
        didSet {
            self.setupCircleViewLineWidth(self.lineWidth, radius: self.radius)
        }
    }
    
    override public var radius: CGFloat {
        didSet {
            self.updateProgressButtonFrame()
            self.setupCircleViewLineWidth(self.lineWidth, radius: self.radius)
        }
    }
    
    override public var startAngle: Float {
        didSet {
            self.updateProgressButtonFrame()
        }
    }
    
    override init(frame: CGRect, radius: CGFloat, width: CGFloat, startAngle: Float) {
        super.init(frame: frame, radius: radius, width: width, startAngle: startAngle)
        
        setupProgressButton()
        updateProgressButtonFrame()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupProgressButton()
        updateProgressButtonFrame()
    }
    
//    MARK: Override
    override func setupCircleViewLineWidth(lineWidth: CGFloat, radius circleRadius: CGFloat) {
        super.setupCircleViewLineWidth(lineWidth, radius: circleRadius)
        
        let layer = self.layer as! CAShapeLayer
        layer.removeAllAnimations()
    }

    
//    MARK: Private
    private func setupProgressButton() {
        progressButton = UIButton(frame: CGRectMake(self.frame.width/2-progressButtonSize/2, radius, progressButtonSize, progressButtonSize))
        progressButton.backgroundColor = UIColor.yellowColor()
        progressButton.addTarget(self, action: "buttonDrag:withEvent:", forControlEvents: UIControlEvents.TouchDragInside)
        progressButton.addTarget(self, action: "buttonDrag:withEvent:", forControlEvents: UIControlEvents.TouchDragOutside)
        
        self.addSubview(progressButton)
    }
    
    private func updateProgressButtonFrame() {
        if self.progress == 0 {
            progressButton.frame = CGRectMake(self.frame.width / 2 - progressButtonSize / 2, (self.frame.height / 2 - lineWidth) - radius,
            progressButtonSize, progressButtonSize)
        }
        
        let angle: Float = self.angleBetweenCenterAndPoint(self.progressButton.center)
        self.progressButton.center = self.pointForAngle(angle)
    }
    
    
//    MARK: Events
    func buttonDrag(button: UIButton, withEvent event:UIEvent) {
        
        if let touch: UITouch = event.allTouches()?.first {
            
            let previousLocation = touch.previousLocationInView(button)
            let location = touch.locationInView(button)
            let deltaX: CGFloat = location.x - previousLocation.x
            let deltaY: CGFloat = location.y - previousLocation.y
            
            button.center = CGPointMake(button.center.x + deltaX, button.center.y + deltaY)
            let angle: Float = self.angleBetweenCenterAndPoint(self.progressButton.center)
            button.center = self.pointForAngle(angle)
            
            let angleForProgress = angle + abs(self.startAngle)
            var progress = angleForProgress / kFullCircleAngle
            
            if progress < 0 {
                progress = (kFullCircleAngle + angleForProgress)/kFullCircleAngle
            }
            
            if self.shouldCrossStartPosition {
                self.progress = CGFloat(progress)
            } else {
                limitProgressIfNeeded(CGFloat(progress), forButton: button, withAngle: angle)
            }
        }
    }

    
//    MARK: angle & point calculation
     func pointForAngle(angle: Float) -> CGPoint {
        let angleRadiant = angle * Float(M_PI) / 180.0
        
        let R: Float = Float(self.radius)
        let newX = R * cos(angleRadiant) + Float(self.frame.width / 2)
        let newY = R * sin(angleRadiant) + Float(self.frame.height / 2)
        return CGPointMake(CGFloat(newX), CGFloat(newY))
    }
    
     func angleBetweenCenterAndPoint(point: CGPoint) -> Float {
        let angle = atan2((point.y - self.frame.height / 2), (point.x - self.frame.width / 2))
        return Float(angle * 180.0/CGFloat(M_PI))
    }
    
    private func clampAngle(let angle : Float) -> Float {
        let maxValue = max(angle, -kMaxAngle)
        return min(maxValue, kMaxAngle)
    }
    
    
//    MARK: Help
    private func limitProgressIfNeeded(progress: CGFloat, forButton button: UIButton, withAngle angle: Float) {
        let kProgressHalf: CGFloat = 0.5
        let kProgressAccuracy: CGFloat = 0.1
        
        if self.progress < kProgressHalf {
            let newAngle: Float = (progress < kProgressHalf+kProgressAccuracy) ? angle : startAngle+90
            let newProgress: CGFloat = (progress < kProgressHalf+kProgressAccuracy) ? progress : 0
            self.progress = newProgress
            button.center = pointForAngle(newAngle)
        } else {
            let newAngle: Float = (progress > kProgressHalf-kProgressAccuracy) ? angle : endAngle+90
            let newProgress: CGFloat = (progress > kProgressHalf-kProgressAccuracy) ? progress : 1
            self.progress = newProgress
            button.center = pointForAngle(newAngle)
        }
    }
}