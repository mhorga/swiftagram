//
//  CropImageViewController.swift
//  Swiftagram
//
//  Created by Marius Horga on 4/6/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit

@objc protocol CropImageViewControllerDelegate {

    func cropControllerFinishedWithImage(croppedImage: UIImage)
}

class CropImageViewController: MediaFullScreenViewController {
    
    var delegate: CropImageViewControllerDelegate?
    var cropBox: CropBox?
    var hasLoadedOnce: Bool?

    init(sourceImage: UIImage) {
        super.init(media: Media(mediaDictionary: NSDictionary()))
        self.media!.image = sourceImage
        self.cropBox = CropBox(frame: UIView().frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.clipsToBounds = true
        self.view.addSubview(self.cropBox!)
        let rightButton = UIBarButtonItem(title: NSLocalizedString("Crop", comment: "Crop command"), style:.Done, target: self, action: "cropPressed")
        self.navigationItem.title = NSLocalizedString("Crop Image", comment: "")
        self.navigationItem.rightBarButtonItem = rightButton
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor(white: 0.8, alpha: 1)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var cropRect = CGRectZero
        let edgeSize = min(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))
        cropRect.size = CGSizeMake(edgeSize, edgeSize)
        let size = self.view.frame.size
        self.cropBox!.frame = cropRect
        self.cropBox!.center = CGPointMake(size.width / 2, size.height / 2)
        self.scrollView!.frame = self.cropBox!.frame
        self.scrollView!.clipsToBounds = false
        self.recalculateZoomScale()
        if self.hasLoadedOnce == false {
            self.scrollView!.zoomScale = self.scrollView!.minimumZoomScale
            self.hasLoadedOnce = true
        }
    }
    
    func cropPressed(sender: UIBarButtonItem) {
        var visibleRect: CGRect?
        let scale = 1.0 / self.scrollView!.zoomScale / self.media!.image!.scale
        visibleRect!.origin.x = self.scrollView!.contentOffset.x * scale
        visibleRect!.origin.y = self.scrollView!.contentOffset.y * scale
        visibleRect!.size.width = self.scrollView!.bounds.size.width * scale
        visibleRect!.size.height = self.scrollView!.bounds.size.height * scale
        var scrollViewCrop = self.media!.image!.imageWithFixedOrientation()
        scrollViewCrop = scrollViewCrop.imageCroppedToRect(visibleRect!)
        self.delegate!.cropControllerFinishedWithImage(scrollViewCrop)
    }
}
