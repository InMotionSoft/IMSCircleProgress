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
            var buttonFame = self.progressButton.frame
            buttonFame.size = CGSizeMake(progressButtonSize, progressButtonSize)
            self.progressButton.frame = buttonFame
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
            self.endAngle = startAngle + kFullCircleAngle
            self.updateProgressButtonFrame()
            self.setupCircleViewLineWidth(self.lineWidth, radius: self.radius)
        }
    }
    
    override public var progressClockwiseDirection: Bool {
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
        
        let layer = self.progressLayer
        layer.removeAllAnimations()
    }
    
    
    //    MARK: Private
    func setupProgressButton() {
        progressButton = UIButton(frame: CGRectMake(self.frame.width/2-progressButtonSize/2, radius, progressButtonSize, progressButtonSize))
        progressButton.backgroundColor = UIColor.whiteColor()
        progressButton.addTarget(self, action: "buttonDrag:withEvent:", forControlEvents: UIControlEvents.TouchDragInside)
        progressButton.addTarget(self, action: "buttonDrag:withEvent:", forControlEvents: UIControlEvents.TouchDragOutside)
        
        self.addSubview(progressButton)
    }
    
    func updateProgressButtonFrame() {
        if self.progress == 0 {
            progressButton.frame = CGRectMake(self.frame.width / 2 - progressButtonSize / 2, (self.frame.height / 2 - lineWidth) - radius,
                progressButtonSize, progressButtonSize)
            self.progressButton.center = self.pointForAngle(self.progressClockwiseDirection ? self.startAngle : self.endAngle)
        } else {
            let angle: Float = self.angleBetweenCenterAndPoint(self.progressButton.center)
            self.progressButton.center = self.pointForAngle(angle)
        }
    }
    
    
    //    MARK: Events
    func buttonDrag(button: UIButton, withEvent event:UIEvent) {
        
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
        
        var progress = self.progressForAngle(angle)
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
        self.progress = CGFloat(progress)
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
    
    func progressForAngle(angle: Float) -> Float {
        var angleForProgress = angle - self.startAngle
        if self.progressClockwiseDirection == false {
            angleForProgress = angle - self.startAngle
        }
        
        let fullCircleAngle = fabsf(self.startAngle) + fabsf(self.endAngle);
        var progress = angleForProgress / fullCircleAngle
        
        if progress < 0 && self.progress > 0.5 {
            progress = (kFullCircleAngle + angleForProgress)/fullCircleAngle
        }
        
        progress = min(Float(1), Float(progress))
        progress = max(Float(0), Float(progress))
        
        return progress
    }
}