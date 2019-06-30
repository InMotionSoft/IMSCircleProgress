//
//  DRCircleDoubleDragProgressView.swift
//  CircleProgress
//
//  Created by Denis Romashov on 02.10.15.
//  Copyright © 2015 InMotion Soft. All rights reserved.
//

import Foundation
import UIKit

open class IMSCircleRangeProgressView: IMSCircleDragProgressView {
    
    open var rangeProgress: (start: CGFloat, end: CGFloat) = (0.0, 0.0) {
        didSet {
            self.updateProgressLayer()
        }
    }
    
    //for objc usage
    open var startRangeProgress: CGFloat {
        get {
            return self.rangeProgress.start
        }
        
        set {
            self.rangeProgress = (newValue, self.rangeProgress.end)
        }
    }
    
    open var endRangeProgress: CGFloat {
        get {
            return self.rangeProgress.end
        }
        
        set {
            self.rangeProgress = (self.rangeProgress.start, newValue)
        }
    }
    //--
    
    fileprivate(set) open var rangeButton1: UIButton!
    
    open var rangeButton1Size: CGFloat = 44 {
        didSet {
            var buttonFame = self.rangeButton1.frame
            buttonFame.size = CGSize(width: rangeButton1Size, height: rangeButton1Size)
            self.rangeButton1.frame = buttonFame
        }
    }
    
    open var rangeButton2: UIButton! {
        get {
            return self.progressButton
        }
    }
    
    open var rangeButton2Size: CGFloat = 44 {
        didSet {
            var buttonFame = self.rangeButton2.frame
            buttonFame.size = CGSize(width: rangeButton2Size, height: rangeButton2Size)
            self.rangeButton2.frame = buttonFame
        }
    }
    
    override open var progressButtonSize: CGFloat {
        get {
            return self.rangeButton1Size
        }
        
        set {
            self.rangeButton1Size = newValue
        }
    }
    
    
    //    MARK: Overrides
    override init(frame: CGRect, radius: CGFloat, width: CGFloat, startAngle: Float) {
        super.init(frame: frame, radius: radius, width: width, startAngle: startAngle)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func updateProgressButtonFrame() {
        super.updateProgressButtonFrame()
        
        if self.rangeProgress.start == 0 && self.rangeProgress.end == 0 {
            rangeButton1.frame = CGRect(x: self.frame.width / 2 - rangeButton1Size / 2, y: (self.frame.height / 2 - lineWidth) - radius,
                                        width: rangeButton1Size, height: rangeButton1Size)
            self.rangeButton1.center = self.pointForAngle(self.startAngle)
        } else {
            let angle: Float = self.angleBetweenCenterAndPoint(self.rangeButton1.center)
            self.rangeButton1.center = self.pointForAngle(angle)
        }
        
        self.updateProgressLayer()
    }
    
    @objc override func buttonDrag(_ button: UIButton, withEvent event:UIEvent) {
        
        var angle: Float = self.angleBetweenCenterAndPoint(button.center)
        guard let touch: UITouch = event.allTouches?.first else {
            return
        }
        
        let previousLocation = touch.previousLocation(in: button)
        let location = touch.location(in: button)
        let deltaX: CGFloat = location.x - previousLocation.x
        let deltaY: CGFloat = location.y - previousLocation.y
        
        button.center = CGPoint(x: button.center.x + deltaX, y: button.center.y + deltaY)
        angle = self.angleBetweenCenterAndPoint(button.center)
        button.center = self.pointForAngle(angle)
        
        self.updateRangeProgress()
    }
    
    override func setupProgressButton() {
        super.setupProgressButton()
        
        rangeButton1 = UIButton(frame: CGRect(x: self.frame.width / 2 - self.rangeButton1Size / 2, y: self.radius,
                                              width: self.rangeButton1Size, height: self.rangeButton1Size))
        rangeButton1.addTarget(self, action: #selector(buttonDrag(_:withEvent:)), for: UIControl.Event.touchDragInside)
        rangeButton1.addTarget(self, action: #selector(buttonDrag(_:withEvent:)), for: UIControl.Event.touchDragOutside)
        rangeButton1.backgroundColor = UIColor.white
        
        self.insertSubview(rangeButton1, belowSubview: self.rangeButton2)
    }
    
    
    //    MARK: Help Methods
    fileprivate func calculateProgressForButton(_ button: UIButton) -> CGFloat {
        let angle: Float = self.angleBetweenCenterAndPoint(button.center)
        let angleForProgress = angle - self.startAngle
        var progress = angleForProgress / kFullCircleAngle
        
        if progress < 0 {
            progress = (kFullCircleAngle + angleForProgress)/kFullCircleAngle
        }
        
        return CGFloat(progress)
    }
    
    fileprivate func updateProgressLayer() {
        let progressCircle = self.progressLayer
        progressCircle?.strokeStart = min(self.rangeProgress.start, self.rangeProgress.end)
        progressCircle?.strokeEnd   = max(self.rangeProgress.start, self.rangeProgress.end)
        progressCircle?.removeAllAnimations()
    }
    
    fileprivate func updateRangeProgress() {
        let potencialStart = self.calculateProgressForButton(self.rangeButton1)
        let potencialEnd   = self.calculateProgressForButton(self.rangeButton2)
        
        self.rangeProgress.start = min(potencialStart, potencialEnd)
        self.rangeProgress.end   = max(potencialStart, potencialEnd)
    }
}
