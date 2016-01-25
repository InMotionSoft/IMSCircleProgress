//
//  IMSCircleDoubleProgressView.swift
//  CircleProgress
//
//  Created by Max on 21.01.16.
//  Copyright © 2016 InMotion Soft. All rights reserved.
//

import Foundation
import UIKit


@objc public class IMSCircleDoubleProgressView: IMSCircleProgressView {
    var secondProgressLayer: CAShapeLayer!
    
    public var secondProgressStrokeColor = UIColor.whiteColor() {
        didSet {
            self.setupCircleViewLineWidth(self.lineWidth, radius: self.radius)
        }
    }
    
    public var firstProgressLayer: CAShapeLayer {
        get {
            return self.progressLayer
        }
        
        set {
            self.progressLayer = newValue
        }
    }
    
    // <= 0.5 is first circle, > 0.5 is second
    override public var progress: CGFloat {
        didSet {
            self.firstProgressLayer.removeAllAnimations()
            
            let finalProgress = self.endlessProgress(progress)
            if finalProgress > 0.5 {
                self.firstProgressLayer.strokeEnd = 1
                self.secondProgressLayer.strokeEnd = (finalProgress - 0.5) * 2
            } else {
                self.secondProgressLayer.strokeEnd = 0
                self.firstProgressLayer.strokeEnd = finalProgress * 2
                self.secondProgressLayer.removeAllAnimations()
            }
            self.delegate?.circleProgressView(self, didChangeProgress: self.progress)
        }

    }
    
    private var currentProgressLayer: CAShapeLayer! {
        get {
            return (self.progress > 0.5) ? self.secondProgressLayer : self.progressLayer
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
        self.secondProgressLayer.strokeEnd = (self.progress > 0.5) ? self.progress : 0
        
        self.firstProgressLayer.strokeEnd = (self.progress > 0.5) ? self.progress * 2 : 0
        
        self.firstProgressLayer.removeAllAnimations()
        self.secondProgressLayer.removeAllAnimations()
    }

}