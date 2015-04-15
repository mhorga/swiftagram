//
//  CameraToolbar.swift
//  Swiftagram
//
//  Created by Marius Horga on 4/4/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit

@objc protocol CameraToolbarDelegate {
    func leftButtonPressedOnToolbar(CameraToolbar)
    func rightButtonPressedOnToolbar(CameraToolbar)
    func cameraButtonPressedOnToolbar(CameraToolbar)
}

class CameraToolbar: UIView {
    
    var leftButton: UIButton?
    var cameraButton: UIButton?
    var rightButton: UIButton?
    var whiteView: UIView?
    var purpleView: UIView?
    var delegate: CameraToolbarDelegate?
    
    convenience init(imageNames: NSArray) {
        self.init()
        self.leftButton = UIButton.buttonWithType(.Custom) as? UIButton
        self.cameraButton = UIButton.buttonWithType(.Custom) as? UIButton
        self.rightButton = UIButton.buttonWithType(.Custom) as? UIButton
        self.leftButton!.addTarget(self, action: "leftButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.cameraButton!.addTarget(self, action: "cameraButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.rightButton!.addTarget(self, action: "rightButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.leftButton!.setImage(UIImage(CGImage: imageNames.firstObject as! CGImage), forState: UIControlState.Normal)
        self.rightButton!.setImage(UIImage(CGImage: imageNames.lastObject as! CGImage), forState:UIControlState.Normal)
        self.cameraButton!.setImage(UIImage(named: "camera"), forState: UIControlState.Normal)
        self.cameraButton!.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 15, 10)
        self.whiteView = UIView()
        self.whiteView!.backgroundColor = UIColor.whiteColor()
        self.purpleView = UIView()
        self.purpleView!.backgroundColor = UIColor(red: 0.345, green: 0.318, blue: 0.424, alpha: 1) /*#58516c*/
        for view in [self.whiteView, self.purpleView, self.leftButton, self.cameraButton, self.rightButton] {
            self.addSubview(view!)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var whiteFrame = self.bounds
        whiteFrame.origin.y += 10
        self.whiteView!.frame = whiteFrame
        let buttonWidth = CGRectGetWidth(self.bounds) / 3
        let buttons = [self.leftButton, self.cameraButton, self.rightButton]
        for i in 0..<3 {
            var button = buttons[i]
            button?.frame = CGRectMake(CGFloat(i) * buttonWidth, 10, buttonWidth, CGRectGetHeight(whiteFrame))
        }
        self.purpleView!.frame = CGRectMake(buttonWidth, 0, buttonWidth, CGRectGetHeight(self.bounds))
        let maskPath = UIBezierPath(roundedRect: self.purpleView!.bounds, byRoundingCorners: UIRectCorner.TopLeft | UIRectCorner.TopRight, cornerRadii:CGSizeMake(10.0, 10.0))
        var maskLayer = CAShapeLayer(layer: layer)
        maskLayer.frame = self.purpleView!.bounds
        maskLayer.path = maskPath.CGPath
        self.purpleView!.layer.mask = maskLayer
    }
    
    // MARK: - Button Handlers
    
    func leftButtonPressed(sender: UIButton) {
        self.delegate!.leftButtonPressedOnToolbar(self)
    }
    
    func rightButtonPressed(sender: UIButton) {
        self.delegate!.rightButtonPressedOnToolbar(self)
    }
    
    func cameraButtonPressed(sender: UIButton) {
        self.delegate!.cameraButtonPressedOnToolbar(self)
    }
}
