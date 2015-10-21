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
    
    private let kProgressHalf: CGFloat = 0.5
    private let kProgressAccuracy: CGFloat = 0.1
    private var previousPoint: CGPoint = CGPointZero
    private var currentAngle: Float = IMSCircleProgressPosition.Top.rawValue
    
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
            self.currentAngle = self.startAngle
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
        progressButton.frame = CGRectMake(self.frame.width / 2 - progressButtonSize / 2, (self.frame.height / 2 - lineWidth) - radius,
                                          progressButtonSize, progressButtonSize)
        self.progressButton.center = pointForAngle(Float(self.currentAngle))
        self.previousPoint = self.progressButton.center
    }
    
    
//    MARK: Events
    func buttonDrag(button: UIButton, withEvent event:UIEvent) {
        
        if let touch: UITouch = event.allTouches()?.first {
            let point = touch.locationInView(self)
            
//            let newPoint: CGPoint = CGPointMake(point.x - self.previousPoint.x, point.y - self.previousPoint.y)
            
//            let velocity: Float = 1
            
//            if newPoint.x < 0 && newPoint.y < 0 {
//                self.currentAngle -= velocity
//            } else {

//            }
            
            
            let angle = angleBetweenCenterAndPoint(point)
            
            let centerPoint = CGPoint (x: self.frame.width / 2, y: self.frame.width / 2);
            let start = angle * Float(M_PI) / 180.0
            let end = angle * Float(M_PI) / 180.0
            UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: CGFloat(start), endAngle: CGFloat(end), clockwise: true);

            
            let progress = (angle >= 0 && angle <= kMaxAngle) ? angle/kFullCircleAngle : (kFullCircleAngle + angle)/kFullCircleAngle
            
            if self.shouldCrossStartPosition {
                self.progress = CGFloat(progress)
                
                let distance: Float = sqrtf(powf(Float(point.x - self.previousPoint.x), 2.0) + powf(Float(point.y - self.previousPoint.y), 2.0))
                self.currentAngle += distance
                
                button.center = pointForAngle(self.currentAngle)
            } else {
                limitProgressIfNeeded(CGFloat(progress), forButton: button, withAngle: angle)
            }
        }
    }

    
//    MARK: angle & point calculation
     func pointForAngle(angle: Float) -> CGPoint {
        let angleRadiant = angle * Float(M_PI) / 180.0
        
//        let R: Float = Float(radius + lineWidth / 2 - progressButtonSize * 0.2) //- progressButtonSize / 4)
        let R: Float = Float(self.radius)//Float(self.frame.width) / 2.0
        let newX = R * cos(angleRadiant) + Float(self.frame.width / 2)//Float(self.radius) * cos(angleRadiant)// + Float(self.frame.width / 2)
        let newY = R * sin(angleRadiant) + Float(self.frame.height / 2)//Float(self.radius) * sin(angleRadiant) + Float(self.frame.height / 2)
//        let invertedY = self.bounds.size.height - (CGFloat(newY) + self.bounds.size.height/2)
        
        return CGPointMake(CGFloat(newX), CGFloat(newY))
    }
    
     func angleBetweenCenterAndPoint(point: CGPoint) -> Float {
        let center: CGPoint = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0)
        let theAngle = atan2(point.x - center.x, center.y - point.y) * 180.0/CGFloat(M_PI);
        return clampAngle(Float(theAngle))
    }
    
    private func clampAngle(let angle : Float) -> Float {
        let maxValue = max(angle, -kMaxAngle)
        return min(maxValue, kMaxAngle)
    }
    
    
//    MARK: Help
    private func limitProgressIfNeeded(progress: CGFloat, forButton button: UIButton, withAngle angle: Float) {
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