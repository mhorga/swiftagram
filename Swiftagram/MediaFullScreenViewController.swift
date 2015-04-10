//
//  MediaFullScreenViewController.swift
//  Swiftagram
//
//  Created by Marius Horga on 4/6/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit

class MediaFullScreenViewController: UIViewController, UIScrollViewDelegate {

    var scrollView: UIScrollView?
    var imageView: UIImageView?
    var media: Media?
    var tap: UITapGestureRecognizer?
    var doubleTap: UITapGestureRecognizer?
    var tapBehind: UITapGestureRecognizer?
    
    init(media: Media) {
        super.init(nibName: nil, bundle: nil)
        self.media = media
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView = UIScrollView()
        self.scrollView!.delegate = self
        self.scrollView!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.scrollView!)
        self.imageView = UIImageView()
        self.imageView!.image = self.media!.image
        self.scrollView!.addSubview(self.imageView!)
        self.scrollView!.contentSize = self.media!.image!.size
        self.tap = UITapGestureRecognizer(target: self, action: "tapFired")
        self.doubleTap = UITapGestureRecognizer(target: self, action: "doubleTapFired")
        self.doubleTap!.numberOfTapsRequired = 2
        self.tap!.requireGestureRecognizerToFail(self.doubleTap!)
        if isPhone() == false {
            self.tapBehind = UITapGestureRecognizer(target: self, action: "tapBehindFired")
            self.tapBehind!.cancelsTouchesInView = false
        }
        self.scrollView!.addGestureRecognizer(self.tap!)
        self.scrollView!.addGestureRecognizer(self.doubleTap!)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.scrollView!.frame = self.view.bounds
        self.recalculateZoomScale()
    }
    
    func recalculateZoomScale() {
        let scrollViewFrameSize = self.scrollView!.frame.size
        var scrollViewContentSize = self.scrollView!.contentSize
        scrollViewContentSize.height /= self.scrollView!.zoomScale
        scrollViewContentSize.width /= self.scrollView!.zoomScale
        let scaleWidth = scrollViewFrameSize.width / scrollViewContentSize.width
        let scaleHeight = scrollViewFrameSize.height / scrollViewContentSize.height
        let minScale = min(scaleWidth, scaleHeight)
        self.scrollView!.minimumZoomScale = minScale
        self.scrollView!.maximumZoomScale = 1
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        self.centerScrollView()
        if isPhone() == false {
            UIApplication.sharedApplication().delegate!.window!!.addGestureRecognizer(self.tapBehind!)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if isPhone() == false {
        UIApplication.sharedApplication().delegate!.window!!.removeGestureRecognizer(self.tapBehind!)
        }
    }
    
    func centerScrollView() {
        self.imageView!.sizeToFit()
        let boundsSize = self.scrollView!.bounds.size
        var contentsFrame = self.imageView!.frame
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - CGRectGetWidth(contentsFrame)) / 2
        } else {
            contentsFrame.origin.x = 0
        }
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - CGRectGetHeight(contentsFrame)) / 2
        } else {
            contentsFrame.origin.y = 0
        }
        self.imageView!.frame = contentsFrame
    }
    
    func isPhone() -> Bool {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Gesture Recognizers
    
    func tapFired(sender: UITapGestureRecognizer) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doubleTapFired(sender: UITapGestureRecognizer) {
        if self.scrollView!.zoomScale == self.scrollView!.minimumZoomScale {
            let locationPoint = sender.locationInView(self.imageView)
            let scrollViewSize = self.scrollView!.bounds.size
            let width = scrollViewSize.width / self.scrollView!.maximumZoomScale
            let height = scrollViewSize.height / self.scrollView!.maximumZoomScale
            let x = locationPoint.x - (width / 2)
            let y = locationPoint.y - (height / 2)
            self.scrollView!.zoomToRect(CGRectMake(x, y, width, height), animated:true)
        } else {
            self.scrollView!.setZoomScale(self.scrollView!.minimumZoomScale, animated: true)
        }
    }
    
    func tapBehindFired(sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Ended {
            let location = sender.locationInView(nil)
            let locationInVC = self.presentedViewController!.view.convertPoint(location, fromView: self.view.window)
            if self.presentedViewController!.view.pointInside(locationInVC, withEvent: nil) == false {
                if self.presentingViewController != nil {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        self.centerScrollView()
    }
}
