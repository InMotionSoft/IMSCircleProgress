//
//  DRCircleDoubleDragProgressView.swift
//  CircleProgress
//
//  Created by Denis Romashov on 02.10.15.
//  Copyright © 2015 InMotion Soft. All rights reserved.
//

import Foundation
import UIKit

@objc public class IMSCircleDoubleDragProgressView: IMSCircleDragProgressView {
    
    public var rangeButton: UIButton!
    
    
//    MARK: Overrides
    override init(frame: CGRect, radius: CGFloat, width: CGFloat, startAngle: Float) {
        super.init(frame: frame, radius: radius, width: width, startAngle: startAngle)
        
        setupRangeButton()
        updateRangeButtonFrame()
    }    

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func setProgress(progress: CGFloat) {
        let baseAngle = angleBetweenCenterAndPoint(rangeButton.center)
        let baseProgress = (baseAngle >= 0 && baseAngle <= kMaxAngle) ? baseAngle/kFullCircleAngle : (kFullCircleAngle + baseAngle)/kFullCircleAngle

        startAngle = IMSCircleProgressPosition.Top.rawValue + baseAngle
        endAngle = kFullCircleAngle + startAngle
        
        let progressButtonAngle = angleBetweenCenterAndPoint(progressButton.center)
        let currentProgress = (progressButtonAngle >= 0 && progressButtonAngle <= kMaxAngle) ? progressButtonAngle/kFullCircleAngle : (kFullCircleAngle + progressButtonAngle)/kFullCircleAngle
        
        let finalProgress = (currentProgress >= baseProgress) ? currentProgress - baseProgress : 1 + currentProgress - baseProgress
        super.setProgress(CGFloat(finalProgress))
    }
    
    override func buttonDrag(button: UIButton, withEvent event:UIEvent) {

        if let touch: UITouch = event.allTouches()?.first {
            let point = touch.locationInView(self)
            let angle = angleBetweenCenterAndPoint(point)
            button.center = pointForAngle(angle)
        }
        
        self.setProgress(0)
    }
    
    
//    MARK: Setup
    private func setupRangeButton() {
        rangeButton = UIButton(frame: CGRectMake(self.frame.width/2-progressButtonSize/2, radius, progressButtonSize, progressButtonSize))
        rangeButton.addTarget(self, action: "buttonDrag:withEvent:", forControlEvents: UIControlEvents.TouchDragInside)
        rangeButton.addTarget(self, action: "buttonDrag:withEvent:", forControlEvents: UIControlEvents.TouchDragOutside)
        rangeButton.backgroundColor = UIColor.redColor()
        
        self.addSubview(rangeButton)
    }
    
    private func updateRangeButtonFrame() {
        rangeButton.frame = CGRectMake(self.frame.width/2-progressButtonSize/2, (self.frame.size.height/2 - lineWidth)-radius, progressButtonSize, progressButtonSize)
    }
}
