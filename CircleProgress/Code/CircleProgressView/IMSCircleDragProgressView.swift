//
//  DRCircleDragProgressView.swift
//  CircleProgress
//
//  Created by Denis Romashov on 24.09.15.
//  Copyright © 2015 InMotion Soft. All rights reserved.
//

import Foundation
import UIKit


@objc public class IMSCircleDragProgressView: IMSCircleProgressView {
    
    public var shouldBoundProgress = false
    
    var progressButton: UIButton!
    var progressButtonSize: CGFloat = 44.0
    var strokeStart: CGFloat = 0.0
    
    private let kProgressHalf: CGFloat = 0.5
    private let kProgressAccuracy: CGFloat = 0.1
    
    override init(frame: CGRect, radius: CGFloat, width: CGFloat, startAngle: Float) {
        super.init(frame: frame, radius: radius, width: width, startAngle: startAngle)
        
        setupProgressButton()
        updateProgressButtonFrame()
        setProgress(0)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
    
//    MARK: Override
    override  public func setProgress(progress: CGFloat) {
        currentProgress = progress
        let circlePath = setupPathWithRadius(radius)
        
        let progressCircle = self.layer as! CAShapeLayer
        progressCircle.path = circlePath.CGPath
        progressCircle.strokeColor = progressStrokeColor.CGColor
        progressCircle.fillColor = progressFillColor.CGColor
        progressCircle.lineWidth = lineWidth
        progressCircle.strokeStart = strokeStart
        progressCircle.strokeEnd = progress
    }
    
    
//    MARK: Private
    func setupProgressButton() {
        progressButton = UIButton(frame: CGRectMake(self.frame.width/2-progressButtonSize/2, radius, progressButtonSize, progressButtonSize))
        progressButton.backgroundColor = UIColor.yellowColor()
        progressButton.addTarget(self, action: "buttonDrag:withEvent:", forControlEvents: UIControlEvents.TouchDragInside)
        progressButton.addTarget(self, action: "buttonDrag:withEvent:", forControlEvents: UIControlEvents.TouchDragOutside)
        
        self.addSubview(progressButton)
    }
    
    func updateProgressButtonFrame() {
            progressButton.frame = CGRectMake(self.frame.width/2-progressButtonSize/2, (self.frame.size.height/2 - lineWidth)-radius, progressButtonSize, progressButtonSize)
        }
    
    
//    MARK: Events
    func buttonDrag(button: UIButton, withEvent event:UIEvent) {
        
        if let touch: UITouch = event.allTouches()?.first {
            let point = touch.locationInView(self)
            let angle = angleBetweenCenterAndPoint(point)
            let progress = (angle >= 0 && angle <= kMaxAngle) ? angle/kFullCircleAngle : (kFullCircleAngle + angle)/kFullCircleAngle
            
            if shouldBoundProgress {
                limitProgressIfNeeded(CGFloat(progress), forButton: button, withAngle: angle)
            } else {
                button.center = pointForAngle(angle)
                self.setProgress(CGFloat(progress))
            }
        }
    }

    
//    MARK: angle & point calculation
     func pointForAngle(angle: Float) -> CGPoint {
        let angleRadiant = angle * Float(M_PI)/180.0
        
        let R: Float = Float(radius + lineWidth / 2 - progressButtonSize / 4)
        let newX = R * sin(angleRadiant)
        let newY = R * cos(angleRadiant)
        
        let invertedY = self.bounds.size.height - (CGFloat(newY) + self.bounds.size.height/2)
        
        return CGPointMake(CGFloat(newX) + self.bounds.size.width/2.0, invertedY)
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
        if currentProgress < kProgressHalf {
            let newAngle: Float = (progress < kProgressHalf+kProgressAccuracy) ? angle : startAngle+90
            let newProgress: CGFloat = (progress < kProgressHalf+kProgressAccuracy) ? progress : 0
            self.setProgress(newProgress)
            button.center = pointForAngle(newAngle)
        } else {
            let newAngle: Float = (progress > kProgressHalf-kProgressAccuracy) ? angle : endAngle+90
            let newProgress: CGFloat = (progress > kProgressHalf-kProgressAccuracy) ? progress : 1
            self.setProgress(newProgress)
            button.center = pointForAngle(newAngle)
        }
    }
}