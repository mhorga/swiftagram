//
//  PostToInstagramViewController.swift
//  Swiftagram
//
//  Created by Marius Horga on 4/3/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit

class PostToInstagramViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate, UIDocumentInteractionControllerDelegate {
    
    var sourceImage: UIImage?
    var previewImageView: UIImageView?
    var photoFilterOperationQueue: NSOperationQueue?
    var filterCollectionView: UICollectionView?
    var filterImages: NSMutableArray?
    var filterTitles: NSMutableArray?
    var sendButton: UIButton?
    var sendBarButton: UIBarButtonItem?
    var documentController: UIDocumentInteractionController?
    
    typealias MYImage = CIImage
    
    convenience init(sourceImage: UIImage) {
        self.init()
        self.sourceImage = sourceImage
        self.previewImageView = UIImageView(image: self.sourceImage)
        self.photoFilterOperationQueue = NSOperationQueue()
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(44, 64)
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        self.filterCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        self.filterCollectionView!.dataSource = self
        self.filterCollectionView!.delegate = self
        self.filterCollectionView!.showsHorizontalScrollIndicator = false
        self.filterImages = NSMutableArray(array: [sourceImage])
        self.filterTitles = NSMutableArray(array: [NSLocalizedString("None", comment: "Label for when no filter is applied to a photo")])
        self.sendButton = UIButton.buttonWithType(.System) as? UIButton
        self.sendButton!.backgroundColor = UIColor(red: 0.345, green: 0.318, blue: 0.424, alpha:1) /*#58516c*/
        self.sendButton!.layer.cornerRadius = 5
        self.sendButton!.setAttributedTitle(sendAttributedString(), forState: .Normal)
        self.sendButton?.addTarget(self, action: "sendButtonPressed", forControlEvents: .TouchUpInside)
        self.sendBarButton = UIBarButtonItem(title: NSLocalizedString("Send", comment: "Send button"), style: .Done, target: self, action: "sendButtonPressed")
        addFiltersToQueue()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.previewImageView!)
        self.view.addSubview(self.filterCollectionView!)
        if CGRectGetHeight(self.view.frame) > 500 {
            self.view.addSubview(self.sendButton!)
        } else {
            self.navigationItem.rightBarButtonItem = self.sendBarButton
        }
        self.filterCollectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.view.backgroundColor = UIColor.whiteColor()
        self.filterCollectionView!.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = NSLocalizedString("Apply Filter", comment: "apply filter view title")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let edgeSize = min(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))
        self.previewImageView!.frame = CGRectMake(0, self.topLayoutGuide.length, edgeSize, edgeSize)
        let buttonHeight = 50 as CGFloat
        let buffer = 10 as CGFloat
        let filterViewYOrigin = CGRectGetMaxY(self.previewImageView!.frame) + buffer
        var filterViewHeight: CGFloat
        if (CGRectGetHeight(self.view.frame) > 500) {
            self.sendButton!.frame = CGRectMake(buffer, CGRectGetHeight(self.view.frame) - buffer - buttonHeight, CGRectGetWidth(self.view.frame) - 2 * buffer, buttonHeight)
            filterViewHeight = CGRectGetHeight(self.view.frame) - filterViewYOrigin - buffer - buffer - CGRectGetHeight(self.sendButton!.frame)
        } else {
            filterViewHeight = CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.previewImageView!.frame) - buffer - buffer
        }
        self.filterCollectionView!.frame = CGRectMake(0, filterViewYOrigin, CGRectGetWidth(self.view.frame), filterViewHeight)
        let flowLayout = self.filterCollectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSizeMake(CGRectGetHeight(self.filterCollectionView!.frame) - 20, CGRectGetHeight(self.filterCollectionView!.frame))
    }
    
    // MARK: - Buttons
    
    func sendAttributedString() -> NSAttributedString {
        let baseString = NSLocalizedString("SEND TO INSTAGRAM", comment: "send to Instagram button text") as NSString
        let range = baseString.rangeOfString(baseString as String)
        let commentString = NSMutableAttributedString(string: baseString as String)
        commentString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Bold", size: 13.0)!, range: range)
        commentString.addAttribute(NSKernAttributeName, value: 1.3, range: range)
        commentString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 0.933, green: 0.933, blue: 0.933, alpha: 1), range: range)
        return commentString
    }
    
    func sendButtonPressed(sender: AnyObject) {
        let instagramURL = NSURL(string: "instagram://location?id=1")
        if UIApplication.sharedApplication().canOpenURL(instagramURL!) {
            let alert = UIAlertView(title: "", message: NSLocalizedString("Add a caption and send your image in the Instagram app.", comment: "send image instructions"), delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: "cancel button"), otherButtonTitles: NSLocalizedString("Send", comment: "Send button"), "")
            alert.alertViewStyle = .PlainTextInput
            var textField = alert.textFieldAtIndex(0)
            textField!.placeholder = NSLocalizedString("Caption", comment: "Caption")
            alert.show()
        } else {
            let alert = UIAlertView(title: NSLocalizedString("No Instagram App", comment: ""), message: NSLocalizedString("The Instagram app isn't installed on your device. Please install it from the App Store.", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "OK button"), otherButtonTitles: "")
            alert.show()
        }
    }
    
    // MARK: - UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: NSInteger) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            let imagedata = UIImageJPEGRepresentation(self.previewImageView!.image, 0.9)
            let tmpDirURL = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            let fileURL = tmpDirURL!.URLByAppendingPathComponent("blocstagram").URLByAppendingPathExtension("igo")
            let success = imagedata?.writeToURL(fileURL, atomically: true)
            if (success == nil) {
                let alert = UIAlertView(title: NSLocalizedString("Couldn't save image", comment: ""), message: NSLocalizedString("Your cropped and filtered photo couldn't be saved. Make sure you have enough disk space and try again.", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "OK button"), otherButtonTitles: "")
                alert.show()
                return
            }
            self.documentController = UIDocumentInteractionController(URL: fileURL)
            self.documentController!.UTI = "com.instagram.exclusivegram"
            self.documentController!.delegate = self
            let caption = alertView.textFieldAtIndex(0)!.text
            if count(caption) > 0 {
                self.documentController!.annotation = ["InstagramCaption": caption]
            }
            if (self.sendButton!.superview != nil) {
                self.documentController!.presentOpenInMenuFromRect(self.sendButton!.bounds, inView: self.sendButton!, animated: true)
            } else {
                self.documentController!.presentOpenInMenuFromBarButtonItem(self.sendBarButton!, animated: true)
            }
        }
    }
    
    // MARK: - UIDocumentInteractionControllerDelegate
    
//    func documentInteractionController(controller: UIDocumentInteractionController, didEndSendingToApplication application: NSString) {
//        NSNotificationCenter.defaultCenter().postNotificationName(ImageFinishedNotification, object: self)
//    }
    
    // MARK: - Photo Filters
    
    func addFiltersToQueue() {
        let sourceCIImage = CIImage(CGImage: self.sourceImage!.CGImage)
        // Noir filter
        self.photoFilterOperationQueue!.addOperationWithBlock({ () -> Void in
            var noirFilter = CIFilter(name: "CIPhotoEffectNoir")
            if (noirFilter != nil) {
                noirFilter.setValue(sourceCIImage, forKey: kCIInputImageKey)
                self.addCIImageToCollectionView(noirFilter.outputImage, withFilterTitle: NSLocalizedString("Noir", comment: "Noir Filter"))
            }
        })
        // Boom filter
        self.photoFilterOperationQueue!.addOperationWithBlock({ () -> Void in
            var boomFilter = CIFilter(name: "CIPhotoEffectProcess")
            if (boomFilter != nil) {
                boomFilter.setValue(sourceCIImage, forKey: kCIInputImageKey)
                self.addCIImageToCollectionView(boomFilter.outputImage, withFilterTitle: NSLocalizedString("Boom", comment: "Boom Filter"))
            }
        })
        // Warm filter
        self.photoFilterOperationQueue!.addOperationWithBlock({ () -> Void in
            var warmFilter = CIFilter(name: "CIPhotoEffectTransfer")
            if (warmFilter != nil) {
                warmFilter.setValue(sourceCIImage, forKey: kCIInputImageKey)
                self.addCIImageToCollectionView(warmFilter.outputImage, withFilterTitle: NSLocalizedString("Warm", comment: "Warm Filter"))
            }
        })
        // Pixel filter
        self.photoFilterOperationQueue!.addOperationWithBlock({ () -> Void in
            var pixelFilter = CIFilter(name: "CIPixellate")
            if (pixelFilter != nil) {
                pixelFilter.setValue(sourceCIImage, forKey: kCIInputImageKey)
                self.addCIImageToCollectionView(pixelFilter.outputImage, withFilterTitle: NSLocalizedString("Pixel", comment: "Pixel Filter"))
            }
        })
        // Moody filter
        self.photoFilterOperationQueue!.addOperationWithBlock({ () -> Void in
            var moodyFilter = CIFilter(name: "CISRGBToneCurveToLinear")
            if (moodyFilter != nil) {
                moodyFilter.setValue(sourceCIImage, forKey:kCIInputImageKey)
                self.addCIImageToCollectionView(moodyFilter.outputImage,  withFilterTitle: NSLocalizedString("Moody", comment: "Moody Filter"))
            }
        })
        // Drunk filter
        self.photoFilterOperationQueue!.addOperationWithBlock({ () -> Void in
            var drunkFilter = CIFilter(name: "CIConvolution5X5")
            var tiltFilter = CIFilter(name: "CIStraightenFilter")
            if (drunkFilter != nil) {
                drunkFilter.setValue(sourceCIImage, forKey: kCIInputImageKey)
                var drunkVector = CIVector(string: "[0.5 0 0 0 0 0 0 0 0 0.05 0 0 0 0 0 0 0 0 0 0 0.05 0 0 0 0.5]")
                drunkFilter.setValue(drunkVector, forKeyPath: "inputWeights")
                var result = drunkFilter.outputImage
                if (tiltFilter != nil) {
                    tiltFilter.setValue(result, forKeyPath: kCIInputImageKey)
                    tiltFilter.setValue(0.2, forKeyPath: kCIInputAngleKey)
                    result = tiltFilter.outputImage
                }
                self.addCIImageToCollectionView(result, withFilterTitle: NSLocalizedString("Drunk", comment: "Drunk Filter"))
            }
        })
        // Film filter
        self.photoFilterOperationQueue!.addOperationWithBlock({ () -> Void in
            var sepiaFilter = CIFilter(name: "CISepiaTone")
            sepiaFilter.setValue(1, forKey: kCIInputIntensityKey)
            sepiaFilter.setValue(sourceCIImage, forKey: kCIInputImageKey)
            let randomFilter = CIFilter(name: "CIRandomGenerator")
            let randomImage = CIFilter(name: "CIRandomGenerator").outputImage
            let otherRandomImage = randomImage.imageByApplyingTransform(CGAffineTransformMakeScale(1.5, 25.0))
            let whiteSpecks = CIFilter(name: "CIColorMatrix", withInputParameters: [kCIInputImageKey: randomImage, "inputRVector": CIVector(x: 0.0, y: 1.0, z: 0.0, w: 0.0), "inputGVector": CIVector(x: 0.0, y: 1.0, z: 0.0, w: 0.0), "inputBVector": CIVector(x: 0.0, y: 1.0, z: 0.0, w: 0.0), "inputAVector": CIVector(x: 0.0, y: 0.01, z: 0.0, w: 0.0), "inputBiasVector": CIVector(x: 0.0, y: 0.0, z: 0.0, w:0.0)])
            let darkScratches = CIFilter(name: "CIColorMatrix", withInputParameters: [kCIInputImageKey: otherRandomImage, "inputRVector": CIVector(x: 3.659, y: 0.0, z: 0.0, w: 0.0), "inputGVector": CIVector(x: 0.0, y: 0.0, z: 0.0, w: 0.0), "inputBVector": CIVector(x: 0.0, y: 0.0, z: 0.0, w: 0.0), "inputAVector": CIVector(x: 0.0, y: 0.0, z: 0.0, w: 0.0), "inputBiasVector": CIVector(x: 0.0, y: 1.0, z: 1.0, w: 1.0)])
            var minimumComponent = CIFilter(name: "CIMinimumComponent")
            var composite = CIFilter(name: "CIMultiplyCompositing")
            if (sepiaFilter != nil && randomFilter != nil && whiteSpecks != nil && darkScratches != nil && minimumComponent != nil && composite != nil) {
                let sepiaImage = sepiaFilter.outputImage
                let whiteSpecksImage = whiteSpecks.outputImage.imageByCroppingToRect(sourceCIImage.extent())
                let sepiaPlusWhiteSpecksImage = CIFilter(name: "CISourceOverCompositing", withInputParameters: [kCIInputImageKey: whiteSpecksImage, kCIInputBackgroundImageKey: sepiaImage]).outputImage
                var darkScratchesImage = darkScratches.outputImage.imageByCroppingToRect(sourceCIImage.extent())
                minimumComponent.setValue(darkScratchesImage, forKey: kCIInputImageKey)
                darkScratchesImage = minimumComponent.outputImage
                composite.setValue(sepiaPlusWhiteSpecksImage, forKey: kCIInputImageKey)
                composite.setValue(darkScratchesImage, forKey: kCIInputBackgroundImageKey)
                self.addCIImageToCollectionView(composite.outputImage, withFilterTitle: NSLocalizedString("Film", comment: "Film Filter"))
            }
        })
    }
    
    func addCIImageToCollectionView(CIImage: MYImage, withFilterTitle filterTitle: NSString) {
        var image = UIImage(CIImage: CIImage, scale: self.sourceImage!.scale, orientation: self.sourceImage!.imageOrientation)
        if (image != nil) {
            // Decompress image
            UIGraphicsBeginImageContextWithOptions(image!.size, false, image!.scale)
            image!.drawAtPoint(CGPointZero)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
            dispatch_async(dispatch_get_main_queue()) {
                let newIndex = self.filterImages!.count
                self.filterImages!.addObject(image!)
                self.filterTitles!.addObject(filterTitle)
                self.filterCollectionView!.insertItemsAtIndexPaths([NSIndexPath(forItem: newIndex, inSection: 0)])
            }
        }
    }
    
    // MARK: - UICollectionView delegate and data source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filterImages!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! UICollectionViewCell
        let imageViewTag = 1000
        let labelTag = 1001
        var thumbnail = cell.contentView.viewWithTag(imageViewTag) as? UIImageView
        var label = cell.contentView.viewWithTag(labelTag) as? UILabel
        let flowLayout = filterCollectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        let thumbnailEdgeSize = flowLayout.itemSize.width
        if (thumbnail == nil) {
            thumbnail = UIImageView(frame: CGRectMake(0, 0, thumbnailEdgeSize, thumbnailEdgeSize))
            thumbnail!.contentMode = .ScaleAspectFill
            thumbnail!.tag = imageViewTag
            thumbnail!.clipsToBounds = true
            cell.contentView.addSubview(thumbnail!)
        }
        if (label == nil) {
            label = UILabel(frame: CGRectMake(0, thumbnailEdgeSize, thumbnailEdgeSize, 20))
            label!.tag = labelTag
            label!.textAlignment = .Center
            label!.font = UIFont(name: "HelveticaNeue-Medium", size: 10)
            cell.contentView.addSubview(label!)
        }
        thumbnail!.image = self.filterImages![indexPath.row] as? UIImage
        label!.text = self.filterTitles![indexPath.row] as? String
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.previewImageView!.image = self.filterImages![indexPath.row] as? UIImage
    }
}
