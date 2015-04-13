//
//  CircleSpinnerView.swift
//  Swiftagram
//
//  Created by Marius Horga on 4/5/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit

class CircleSpinnerView: UIView {
    
    var strokeThickness: CGFloat?
    var radius: CGFloat?
    var strokeColor: UIColor?
    var circleLayer: CAShapeLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.strokeThickness = 1
        self.radius = 12
        self.strokeColor = UIColor.purpleColor()
        circlelayer()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func willMoveToSuperview(newSuperview: UIView?) {
        if (newSuperview != nil) {
            self.layoutAnimatedLayer()
        }
        else {
            self.circleLayer!.removeFromSuperlayer()
            self.circleLayer = nil
        }
    }
    
    func layoutAnimatedLayer() {
        self.layer.addSublayer(self.circleLayer)
        self.circleLayer!.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
    
    func circlelayer() -> CAShapeLayer {
        if(self.circleLayer == nil) {
            let arcCenter = CGPointMake(self.radius!+self.strokeThickness!/2+5, self.radius!+self.strokeThickness!/2+5)
            let rect = CGRectMake(0, 0, arcCenter.x*2, arcCenter.y*2);
            let smoothedPath = UIBezierPath(arcCenter: arcCenter, radius: self.radius!, startAngle: CGFloat(M_PI*3/2), endAngle: CGFloat(M_PI/2+M_PI*5), clockwise: true)
            self.circleLayer = CAShapeLayer()
            self.circleLayer!.contentsScale = UIScreen.mainScreen().scale
            self.circleLayer!.frame = rect
            self.circleLayer!.fillColor = UIColor.clearColor().CGColor
            self.circleLayer!.strokeColor = self.strokeColor!.CGColor
            self.circleLayer!.lineWidth = self.strokeThickness!
            self.circleLayer!.lineCap = kCALineCapRound
            self.circleLayer!.lineJoin = kCALineJoinBevel
            self.circleLayer!.path = smoothedPath.CGPath
            var maskLayer = CALayer()
            //maskLayer.contents = UIImage(named: "angle-mask")!.CGImage
            maskLayer.frame = self.circleLayer!.bounds
            self.circleLayer!.mask = maskLayer
            let animationDuration = 1 as CFTimeInterval
            let linearCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            let animation = CABasicAnimation(keyPath: "transform.rotation")
            animation.fromValue = 0
            animation.toValue = M_PI*2
            animation.duration = animationDuration
            animation.timingFunction = linearCurve
            animation.removedOnCompletion = false
            animation.repeatCount = Float.infinity
            animation.fillMode = kCAFillModeForwards
            animation.autoreverses = false
            self.circleLayer!.mask.addAnimation(animation, forKey: "rotate")
            let animationGroup = CAAnimation()
            animationGroup.duration = animationDuration
            animationGroup.repeatCount = Float.infinity
            animationGroup.removedOnCompletion = false
            animationGroup.timingFunction = linearCurve
            let strokeStartAnimation = CAPropertyAnimation(keyPath: "strokeStart")
            //strokeStartAnimation.fromValue = 0.015
            //strokeStartAnimation.toValue = 0.515
            let strokeEndAnimation = CAPropertyAnimation(keyPath: "strokeEnd")
            //strokeEndAnimation.fromValue = 0.485
            //strokeEndAnimation.toValue = 0.985
            //animationGroup.animations = [strokeStartAnimation, strokeEndAnimation]
            self.circleLayer!.addAnimation(animationGroup, forKey: "progress")
        }
        return self.circleLayer!
    }
    
    func setRadius(radius: CGFloat) {
        self.radius = radius
        self.circleLayer!.removeFromSuperlayer()
        self.circleLayer = nil
        self.layoutAnimatedLayer()
    }
    
    func setStrokeThickness(strokeThickness: CGFloat) {
        self.strokeThickness = strokeThickness
        self.circleLayer!.lineWidth = self.strokeThickness!
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        return CGSizeMake((self.radius!+self.strokeThickness!/2+5)*2, (self.radius!+self.strokeThickness!/2+5)*2);
    }
}
