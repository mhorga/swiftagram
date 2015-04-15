//
//  MediaFullScreenAnimator.swift
//  Swiftagram
//
//  Created by Marius Horga on 4/10/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit

class MediaFullScreenAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    var presenting: Bool?
    var cellImageView: UIImageView?
    
    @objc func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.2
    }
    
    @objc func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        if self.presenting != nil {
            var fullScreenVC = toViewController as! MediaFullScreenViewController
            fromViewController!.view.userInteractionEnabled = false
            transitionContext.containerView().addSubview(fromViewController!.view)
            transitionContext.containerView().addSubview(toViewController!.view)
            let startFrame = transitionContext.containerView().convertRect(self.cellImageView!.bounds, fromView: self.cellImageView)
            let endFrame = fromViewController!.view.frame
            toViewController!.view.frame = startFrame
            fullScreenVC.imageView!.frame = toViewController!.view.bounds
            UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
                fromViewController!.view.tintAdjustmentMode = UIViewTintAdjustmentMode.Dimmed
                fullScreenVC.view.frame = endFrame
                fullScreenVC.centerScrollView()
            }, completion: { (finished: Bool) in
                transitionContext.completeTransition(true)
            })
        }
        else {
            transitionContext.containerView().addSubview(toViewController!.view)
            transitionContext.containerView().addSubview(fromViewController!.view)
            var fullScreenVC = fromViewController as! MediaFullScreenViewController
            let endFrame = transitionContext.containerView().convertRect(self.cellImageView!.bounds, fromView: self.cellImageView)
            let imageStartFrame = fullScreenVC.view.convertRect(fullScreenVC.imageView!.frame, fromView: fullScreenVC.scrollView)
            var imageEndFrame = transitionContext.containerView().convertRect(endFrame, toView: fullScreenVC.view)
            imageEndFrame.origin.y = 0
            fullScreenVC.view.addSubview(fullScreenVC.imageView!)
            fullScreenVC.imageView!.frame = imageStartFrame
            fullScreenVC.imageView!.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin
            toViewController!.view.userInteractionEnabled = true
            UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
                fullScreenVC.view.frame = endFrame
                fullScreenVC.imageView!.frame = imageEndFrame
                toViewController!.view.tintAdjustmentMode = UIViewTintAdjustmentMode.Automatic
            }, completion: { (finished: Bool) in
                transitionContext.completeTransition(true)
            })
        }
    }
}
