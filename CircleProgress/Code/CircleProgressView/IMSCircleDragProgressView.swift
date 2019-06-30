//
//  DRCircleDragProgressView.swift
//  CircleProgress
//
//  Created by Denis Romashov on 24.09.15.
//  Copyright © 2015 InMotion Soft. All rights reserved.
//

import Foundation
import UIKit


@objc open class IMSCircleDragProgressView: IMSCircleProgressView {
    
    @objc open var shouldCrossStartPosition = false
    
    fileprivate(set) open var progressButton: UIButton!
    @objc open var progressButtonSize: CGFloat = 44.0 {
        didSet {
            var buttonFame = self.progressButton.frame
            buttonFame.size = CGSize(width: progressButtonSize, height: progressButtonSize)
            self.progressButton.frame = buttonFame
            self.updateProgressButtonFrame()
        }
    }
    
    var strokeStart: CGFloat = 0.0
    override open var progress: CGFloat {
        willSet {
            if self.noNeedChangeProgress {
                return
            }
            
            if progress == 0 {
                let startAngle = (self.progressClockwiseDirection) ? self.startAngle : self.endAngle
                let startPoint = self.pointForAngle(startAngle)
                
                if startPoint.equalTo(self.progressButton.center) {
                    let angle: Float = self.angleForProgress(newValue)
                    self.progressButton.center = self.pointForAngle(angle)
                }
            }
        }
        
        didSet {
            if self.noNeedChangeProgress {
                self.noNeedChangeProgress = false;
                return
            }
            
            self.setupCircleViewLineWidth(self.lineWidth, radius: self.radius)
        }
    }
    
    private var noNeedChangeProgress: Bool = false
    
    open func setProgressAndUpdateButtonPosition(_ progress: CGFloat, animated: Bool) {
        
        self.noNeedChangeProgress = true
        let finalProgress = self.endlessProgress(progress)
        
        if animated {
            let progressDif = abs(self.progress - progress)
            
            if progressDif > 0 {
                let time: TimeInterval = TimeInterval(progressDuration * progressDif)
                self.moveProgressButtonAnimatedToProgress(finalProgress, time: time)
            }
            self.progress = finalProgress
            
        } else {
            self.progress = finalProgress
            let angle: Float = self.angleForProgress(self.progress)
            self.progressButton.center = self.pointForAngle(angle)
        }
    }
    
    private func moveProgressButtonAnimatedToProgress(_ progress: CGFloat, time: TimeInterval) {
        
        let buttonAnimation = CAKeyframeAnimation(keyPath: "position")
        let startAngle = self.angleForProgress(self.progress)
        let endAngle = self.angleForProgress(progress)
        
        let moveDirection = (self.progress < progress) ? self.progressClockwiseDirection : !self.progressClockwiseDirection
        
        let center = CGPoint.init(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        let path = UIBezierPath.init(arcCenter: center, radius: self.radius, startAngle: CGFloat(startAngle.degreesToRadians), endAngle: CGFloat(endAngle.degreesToRadians), clockwise: moveDirection)
        
        buttonAnimation.path                  = path.cgPath
        buttonAnimation.fillMode              = CAMediaTimingFillMode.both
        buttonAnimation.isRemovedOnCompletion = false
        buttonAnimation.duration              = time
        buttonAnimation.calculationMode       = CAAnimationCalculationMode.paced
        buttonAnimation.timingFunction        = CAMediaTimingFunction(name:CAMediaTimingFunctionName.linear)
        self.progressButton.layer.add(buttonAnimation, forKey:nil)
    }
    
    override open var radius: CGFloat {
        didSet {
            self.updateProgressButtonFrame()
            self.setupCircleViewLineWidth(self.lineWidth, radius: self.radius)
        }
    }
    
    override open var startAngle: Float {
        didSet {
            self.endAngle = startAngle + kFullCircleAngle
            self.updateProgressButtonFrame()
            self.setupCircleViewLineWidth(self.lineWidth, radius: self.radius)
        }
    }
    
    override open var progressClockwiseDirection: Bool {
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
    override func setupCircleViewLineWidth(_ lineWidth: CGFloat, radius circleRadius: CGFloat) {
        super.setupCircleViewLineWidth(lineWidth, radius: circleRadius)
        
        let layer = self.progressLayer
        layer?.removeAllAnimations()
    }
    
    
    //    MARK: Private
    func setupProgressButton() {
        progressButton = UIButton(frame: CGRect(x: self.frame.width/2-progressButtonSize/2, y: radius, width: progressButtonSize, height: progressButtonSize))
        progressButton.backgroundColor = UIColor.white
        progressButton.addTarget(self, action: #selector(IMSCircleDragProgressView.buttonDrag(_:withEvent:)), for: UIControl.Event.touchDragInside)
        progressButton.addTarget(self, action: #selector(IMSCircleDragProgressView.buttonDrag(_:withEvent:)), for: UIControl.Event.touchDragOutside)
        
        self.addSubview(progressButton)
    }
    
    func updateProgressButtonFrame() {
        if self.progress == 0 {
            progressButton.frame = CGRect(x: self.frame.width / 2 - progressButtonSize / 2, y: (self.frame.height / 2 - lineWidth) - radius,
                                          width: progressButtonSize, height: progressButtonSize)
            self.progressButton.center = self.pointForAngle(self.progressClockwiseDirection ? self.startAngle : self.endAngle)
        } else {
            let angle: Float = self.angleBetweenCenterAndPoint(self.progressButton.center)
            self.progressButton.center = self.pointForAngle(angle)
        }
    }
    
    
    //    MARK: Events
    @objc func buttonDrag(_ button: UIButton, withEvent event:UIEvent) {
        
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
    func pointForAngle(_ angle: Float) -> CGPoint {
        let angleRadiant = angle * Float.pi / 180.0
        
        let R: Float = Float(self.radius)
        let newX = R * cos(angleRadiant) + Float(self.frame.width / 2)
        let newY = R * sin(angleRadiant) + Float(self.frame.height / 2)
        
        return CGPoint(x: CGFloat(newX), y: CGFloat(newY))
    }
    
    func angleBetweenCenterAndPoint(_ point: CGPoint) -> Float {
        let angle = atan2((point.y - self.frame.height / 2), (point.x - self.frame.width / 2))
        return Float(angle * 180.0/CGFloat.pi)
    }
    
    func progressForAngle(_ angle: Float) -> Float {
        let angleForProgress = angle - self.startAngle
        let fullCircleAngle = fabsf(self.startAngle) + fabsf(self.endAngle);
        var progress = angleForProgress / fullCircleAngle
        
        if progress < 0 && self.progress > 0.5 {
            progress = (kFullCircleAngle + angleForProgress)/fullCircleAngle
        }
        
        progress = min(Float(1), Float(progress))
        progress = max(Float(0), Float(progress))
        
        return progress
    }
    
    func angleForProgress(_ progress: CGFloat) -> Float {
        
        let correctionAngle: Float = 90;
        let correctedStartAngle = self.startAngle + correctionAngle
        let correctedEndAngle = self.endAngle + correctionAngle
        
        var angle: Float = (self.progressClockwiseDirection) ? correctedStartAngle : correctedEndAngle
        
        var currentProgress: CGFloat = 0
        let intProgress = Int(progress * 1000)
        let fullCircleAngle = kFullCircleAngle - fabsf(correctedStartAngle - correctedEndAngle)
        
        var angleStep = 0.0001 * fullCircleAngle
        while (Int(currentProgress) != intProgress) {
            
            if abs(Int(currentProgress) - intProgress) > 100 {
                angleStep = 0.1 * fullCircleAngle
                currentProgress += 100
            } else {
                angleStep = 0.0001 * fullCircleAngle
                currentProgress += 0.1
            }
            
            if self.progressClockwiseDirection {
                angle += angleStep
            } else {
                angle -= angleStep
            }
        }
        
        angle -= correctionAngle
        return angle
    }
}
