//
//  DRCircleDoubleDragProgressView.swift
//  CircleProgress
//
//  Created by Denis Romashov on 02.10.15.
//  Copyright © 2015 InMotion Soft. All rights reserved.
//

import Foundation
import UIKit

public class IMSCircleRangeProgressView: IMSCircleDragProgressView {
    
    public var rangeProgress: (start: CGFloat, end: CGFloat) = (0.0, 0.0) {
        didSet {
            self.updateProgressLayer()
        }
    }
    
    private(set) public var rangeButton1: UIButton!
    
    public var rangeButton1Size: CGFloat = 44 {
        didSet {
            var buttonFame = self.rangeButton1.frame
            buttonFame.size = CGSizeMake(rangeButton1Size, rangeButton1Size)
            self.rangeButton1.frame = buttonFame
        }
    }
    
    public var rangeButton2: UIButton! {
        get {
            return self.progressButton
        }
    }
    
    public var rangeButton2Size: CGFloat = 44 {
        didSet {
            var buttonFame = self.rangeButton2.frame
            buttonFame.size = CGSizeMake(rangeButton2Size, rangeButton2Size)
            self.rangeButton2.frame = buttonFame
        }
    }
    
    override public var progressButtonSize: CGFloat {
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
            rangeButton1.frame = CGRectMake(self.frame.width / 2 - rangeButton1Size / 2, (self.frame.height / 2 - lineWidth) - radius,
                rangeButton1Size, rangeButton1Size)
            self.rangeButton1.center = self.pointForAngle(self.startAngle)
        } else {
            let angle: Float = self.angleBetweenCenterAndPoint(self.rangeButton1.center)
            self.rangeButton1.center = self.pointForAngle(angle)
        }
        
        self.updateProgressLayer()
    }
    
    override func buttonDrag(button: UIButton, withEvent event:UIEvent) {

        var angle: Float = self.angleBetweenCenterAndPoint(button.center)
        guard let touch: UITouch = event.allTouches()?.first else {
            return
        }
        
        let previousLocation = touch.previousLocationInView(button)
        let location = touch.locationInView(button)
        let deltaX: CGFloat = location.x - previousLocation.x
        let deltaY: CGFloat = location.y - previousLocation.y
        
        button.center = CGPointMake(button.center.x + deltaX, button.center.y + deltaY)
        angle = self.angleBetweenCenterAndPoint(button.center)
        button.center = self.pointForAngle(angle)

        self.updateRangeProgress()
    }
    
    override func setupProgressButton() {
        super.setupProgressButton()
        
        rangeButton1 = UIButton(frame: CGRectMake(self.frame.width / 2 - self.rangeButton1Size / 2, self.radius,
            self.rangeButton1Size, self.rangeButton1Size))
        rangeButton1.addTarget(self, action: "buttonDrag:withEvent:", forControlEvents: UIControlEvents.TouchDragInside)
        rangeButton1.addTarget(self, action: "buttonDrag:withEvent:", forControlEvents: UIControlEvents.TouchDragOutside)
        rangeButton1.backgroundColor = UIColor.whiteColor()
        
        self.insertSubview(rangeButton1, belowSubview: self.rangeButton2)
    }

//    MARK: Help Methods
    private func calculateProgressForButton(button: UIButton) -> CGFloat {
        let angle: Float = self.angleBetweenCenterAndPoint(button.center)
        let angleForProgress = angle - self.startAngle
        var progress = angleForProgress / kFullCircleAngle
        
        if progress < 0 {
            progress = (kFullCircleAngle + angleForProgress)/kFullCircleAngle
        }
        
        return CGFloat(progress)
    }
    
    private func updateProgressLayer() {
        let progressCircle = self.layer as! CAShapeLayer
        progressCircle.strokeStart = min(self.rangeProgress.start, self.rangeProgress.end)
        progressCircle.strokeEnd   = max(self.rangeProgress.start, self.rangeProgress.end)
    }
    
    private func updateRangeProgress() {
        let potencialStart = self.calculateProgressForButton(self.rangeButton1)
        let potencialEnd   = self.calculateProgressForButton(self.rangeButton2)
        
        self.rangeProgress.start = min(potencialStart, potencialEnd)
        self.rangeProgress.end   = max(potencialStart, potencialEnd)
    }
}
