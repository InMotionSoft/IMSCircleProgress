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
    @IBOutlet weak var circleProgress: IMSCircleDoubleProgressView!
    @IBOutlet weak var circleDoubleProgress: IMSCircleDoubleDragProgressView!
    
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var prgressTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCircleProgress()
    }
    
    fileprivate func setupCircleProgress() {
        
        
        circleProgress.backgroundColor = UIColor.clear
        circleProgress.radius = 55
        circleProgress.lineWidth = 8
        circleProgress.progressStrokeColor = UIColor.orange
        circleProgress.secondProgressStrokeColor = UIColor.blue
        circleProgress.progress = 0
        circleProgress.progressStrokeWithRoundCorner = true
        
        
        dragProgress.progressStrokeColor = UIColor.green
        dragProgress.backgroundColor = UIColor.clear
        dragProgress.radius = 55
        dragProgress.lineWidth = 6
        dragProgress.shouldCrossStartPosition = false
        dragProgress.progressButton.backgroundColor = UIColor.white
        dragProgress.progressButton.alpha = 0.5
        dragProgress.progressButtonSize = 30
        dragProgress.progressButton.layer.cornerRadius = dragProgress.progressButtonSize / 2
        dragProgress.startAngle = -40 //IMSCircleProgressPosition.Top.rawValue
        dragProgress.endAngle = 220
//        dragProgress.progressClockwiseDirection = false

        
        testDragProgress.backgroundColor = UIColor.clear
        testDragProgress.radius = 55
        testDragProgress.lineWidth = 6
        testDragProgress.rangeButton1.backgroundColor = UIColor.blue
        testDragProgress.progressStrokeColor = UIColor.white
        testDragProgress.rangeButton1.layer.cornerRadius = testDragProgress.rangeButton1.frame.size.width/2

        testDragProgress.rangeButton2.backgroundColor = UIColor.orange
        testDragProgress.rangeButton2.layer.cornerRadius = testDragProgress.rangeButton2.frame.size.width/2

        
        circleDoubleProgress.progressStrokeColor = UIColor.green
        circleDoubleProgress.backgroundColor = UIColor.clear
        circleDoubleProgress.radius = 55
        circleDoubleProgress.lineWidth = 6
        circleDoubleProgress.shouldCrossStartPosition = true
        circleDoubleProgress.progressButton.backgroundColor = UIColor.white
        circleDoubleProgress.progressButton.alpha = 0.5
        circleDoubleProgress.progressButtonSize = 30
        circleDoubleProgress.progressButton.layer.cornerRadius = dragProgress.progressButtonSize / 2
        
        circleDoubleProgress.animatedProgress = false
        circleDoubleProgress.secondProgressStrokeColor = UIColor.blue
    }
    
    
//    MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
//    MARK: Actions
    @IBAction func changeProgress(_ sender: AnyObject) {
        
        if let progressText = prgressTextField.text {
            let numberFormatter = NumberFormatter()
            if let number = numberFormatter.number(from: progressText) {
                circleProgress.progress = CGFloat(number.floatValue)
            }
        }
    }
    
    @IBAction func changeRadius(_ sender: AnyObject) {
        
        guard let radiusText = radiusTextField.text else {
            return
        }
        
        let numberFormatter = NumberFormatter()
        
        if let number = numberFormatter.number(from: radiusText) {
            self.circleProgress.radius = CGFloat(number.floatValue)
            self.dragProgress.radius = CGFloat(number.floatValue)
            self.testDragProgress.radius = CGFloat(number.floatValue)
        }
    }
}

