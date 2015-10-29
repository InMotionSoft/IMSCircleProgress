//
//  ViewController.swift
//  CircleProgress
//
//  Created by Denis Romashov on 23.09.15.
//  Copyright © 2015 InMotion Soft. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var testDragProgress: IMSCircleRangeProgressView!
    @IBOutlet weak var dragProgress: IMSCircleDragProgressView!
    @IBOutlet weak var circleProgress: IMSCircleProgressView!
    
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var prgressTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCircleProgress()
    }
    
    private func setupCircleProgress() {
                
        circleProgress.backgroundColor = UIColor.clearColor()
        circleProgress.radius = 55
        circleProgress.lineWidth = 8
        circleProgress.progressStrokeColor = UIColor.orangeColor()
        
        dragProgress.progressStrokeColor = UIColor.greenColor()
        dragProgress.backgroundColor = UIColor.clearColor()
        dragProgress.radius = 55
        dragProgress.lineWidth = 6
        dragProgress.shouldCrossStartPosition = false
        dragProgress.progressButton.backgroundColor = UIColor.whiteColor()
        dragProgress.progressButton.alpha = 0.5
        dragProgress.progressButtonSize = 40
        dragProgress.progressButton.layer.cornerRadius = dragProgress.progressButtonSize / 2
        dragProgress.startAngle = -40 //IMSCircleProgressPosition.Top.rawValue
        dragProgress.endAngle = 220
//        dragProgress.progressClockwiseDirection = false

        testDragProgress.backgroundColor = UIColor.clearColor()
        testDragProgress.radius = 140
        testDragProgress.lineWidth = 6
        testDragProgress.rangeButton1.backgroundColor = UIColor.blueColor()
        testDragProgress.progressStrokeColor = UIColor.whiteColor()
        testDragProgress.rangeButton1.layer.cornerRadius = testDragProgress.rangeButton1.frame.size.width/2

        testDragProgress.rangeButton2.backgroundColor = UIColor.orangeColor()
        testDragProgress.rangeButton2.layer.cornerRadius = testDragProgress.rangeButton2.frame.size.width/2
    }
    
    
//    MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
//    MARK: Actions
    @IBAction func changeProgress(sender: AnyObject) {
        
        if let progressText = prgressTextField.text {
            let numberFormatter = NSNumberFormatter()
            if let number = numberFormatter.numberFromString(progressText) {
                circleProgress.progress = CGFloat(number.floatValue)
            }
        }
    }
    
    @IBAction func changeRadius(sender: AnyObject) {
        
        guard let radiusText = radiusTextField.text else {
            return
        }
        
        let numberFormatter = NSNumberFormatter()
        
        if let number = numberFormatter.numberFromString(radiusText) {
            self.circleProgress.radius = CGFloat(number.floatValue)
            self.dragProgress.radius = CGFloat(number.floatValue)
            self.testDragProgress.radius = CGFloat(number.floatValue)
        }
    }
}

