//
//  CropBox.swift
//  Swiftagram
//
//  Created by Marius Horga on 4/4/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit

class CropBox: UIView {
    
    var horizontalLines: NSArray?
    var verticalLines: NSArray?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.userInteractionEnabled = false
//        let lines = self.horizontalLines!.arrayByAddingObjectsFromArray(self.verticalLines! as [AnyObject]) as NSArray
//        for lineView in lines {
//            self.addSubview(lineView as! UIView)
//        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func horizontallines() -> NSArray {
        if self.horizontalLines == nil {
            self.horizontalLines = self.newArrayOfFourWhiteViews()
        }
        return self.horizontalLines!
    }
    
    func verticallines() -> NSArray {
        if self.verticalLines == nil {
            self.verticalLines = self.newArrayOfFourWhiteViews()
        }
        return self.verticalLines!
    }
    
    func newArrayOfFourWhiteViews() -> NSArray {
        var array = NSMutableArray()
        for i in 0..<4 {
            var view = UIView()
            view.backgroundColor = UIColor.whiteColor()
            array.addObject(view)
        }
        return array
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = CGRectGetWidth(self.frame)
        let thirdOfWidth = width / 3
//        for i in 0..<4 {
//            let horizontalLine = self.horizontalLines![i] as! UIView
//            let verticalLine = self.verticalLines![i] as! UIView
//            horizontalLine.frame = CGRectMake(0, (CGFloat(i) * thirdOfWidth), width, 0.5)
//            var verticalFrame = CGRectMake(CGFloat(i) * thirdOfWidth, 0, 0.5, width)
//            if i == 3 {
//                verticalFrame.origin.x -= 0.5
//            }
//            verticalLine.frame = verticalFrame
//        }
    }
}
