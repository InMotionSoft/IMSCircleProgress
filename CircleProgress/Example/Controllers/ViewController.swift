//
//  ViewController.swift
//  CircleProgress
//
//  Created by Denis Romashov on 23.09.15.
//  Copyright © 2015 InMotion Soft. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var testDragProgress: IMSCircleDoubleDragProgressView!
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
//        circleProgress.initProgressViewWithRadius(55, lineWidth: 8.0)
        circleProgress.setProgress(0.25)
        
//        dragProgress.progressButtonSize = 30.0
//        dragProgress.progressStrokeColor = UIColor.greenColor()
//        dragProgress.backgroundColor = UIColor.clearColor()
////        dragProgress.initProgressViewWithRadius(55.0, lineWidth: 6.0)
//        dragProgress.shouldBoundProgress = true
//        dragProgress.progressButton.backgroundColor = UIColor.whiteColor()
//        dragProgress.progressButton.alpha = 0.5

//        testDragProgress.progressStrokeColor = UIColor.whiteColor()
//        testDragProgress.backgroundColor = UIColor.clearColor()
////        testDragProgress.initProgressViewWithRadius(140.0, lineWidth: 12.0)
//        testDragProgress.rangeButton.layer.cornerRadius = testDragProgress.rangeButton.frame.size.width/2
//        testDragProgress.progressButton.layer.cornerRadius = testDragProgress.progressButton.frame.size.width/2
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
                circleProgress.setProgress(CGFloat(number.floatValue))
            }
        }
    }
    
    @IBAction func changeRadius(sender: AnyObject) {
        
        if let radiusText = radiusTextField.text {
            let numberFormatter = NSNumberFormatter()
            if let number = numberFormatter.numberFromString(radiusText) {
                self.circleProgress.radius = CGFloat(number.floatValue)
//                circleProgress.initProgressViewWithRadius(CGFloat(number.floatValue), lineWidth: 8.0)
            }
        }
    }
    
}

