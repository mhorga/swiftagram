//
//  CameraViewController.swift
//  Swiftagram
//
//  Created by Marius Horga on 4/4/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol CameraViewControllerDelegate {
    optional func cameraViewController(AnyObject, didCompleteWithImage image: UIImage?)
}

class CameraViewController: UIViewController, UIAlertViewDelegate, CameraToolbarDelegate, ImageLibraryViewControllerDelegate {
    
    var imagePreview: UIView?
    var session: AVCaptureSession?
    var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    var stillImageOutput: AVCaptureStillImageOutput?
    var topView: UIToolbar?
    var bottomView: UIToolbar?
    var cropBox: CropBox?
    var cameraToolbar: CameraToolbar?
    var delegate: CameraViewControllerDelegate?
    
    // MARK: - Build View Hierarchy
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createViews()
        self.addViewsToViewHierarchy()
        self.setupImageCapture()
        self.createCancelButton()
    }
    
    func createViews() {
        self.imagePreview = UIView()
        self.topView = UIToolbar()
        self.bottomView = UIToolbar()
        self.cropBox = CropBox(frame: self.imagePreview!.frame)
        self.cameraToolbar = CameraToolbar(imageNames: ["rotate", "road"])
        self.cameraToolbar!.delegate = self
        let whiteBG = UIColor(white: 1.0, alpha: 0.15)
        self.topView!.barTintColor = whiteBG
        self.bottomView!.barTintColor = whiteBG
        self.topView!.alpha = 0.5
        self.bottomView!.alpha = 0.5
    }
    
    func addViewsToViewHierarchy() {
        var views = [self.imagePreview, self.cropBox, self.topView, self.bottomView]
        views.append(self.cameraToolbar)
        for view in views {
            self.view.addSubview(view!)
        }
    }
    
    func setupImageCapture() {
        self.session = AVCaptureSession()
        self.session!.sessionPreset = AVCaptureSessionPresetHigh
        self.captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        self.captureVideoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.captureVideoPreviewLayer!.masksToBounds = true
        self.imagePreview!.layer.addSublayer(self.captureVideoPreviewLayer)
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted: Bool) in
            dispatch_async(dispatch_get_main_queue()) {
                if granted == true {
                    let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
                    var error: NSError?
                    let input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error) as? AVCaptureDeviceInput
                    if input == nil {
                        let alert = UIAlertView(title: error!.localizedDescription, message: error!.localizedRecoverySuggestion, delegate: self, cancelButtonTitle: NSLocalizedString("OK", comment: "OK button"))
                        alert.show()
                    } else {
                        self.session!.addInput(input)
                        self.stillImageOutput = AVCaptureStillImageOutput()
                        self.stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                        self.session!.addOutput(self.stillImageOutput)
                        self.session!.startRunning()
                    }
                } else {
                    let alert = UIAlertView(title: NSLocalizedString("Camera Permission Denied", comment: "camera permission denied title"), message: NSLocalizedString("This app doesn't have permission to use the camera; please update your privacy settings.", comment: "camera permission denied recovery suggestion"), delegate: self, cancelButtonTitle: NSLocalizedString("OK", comment: "OK button"))
                    alert.show()
                }
            }
        })
    }
    
    func createCancelButton() {
        let cancelImage = UIImage(named: "x")
        let cancelButton = UIBarButtonItem(image: cancelImage, style: UIBarButtonItemStyle.Done, target: self, action: "cancelPressed")
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    // MARK: - Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let width = CGRectGetWidth(self.view.bounds)
        self.topView!.frame = CGRectMake(0, self.topLayoutGuide.length, width, 44)
        let yOriginOfBottomView = CGRectGetMaxY(self.topView!.frame) + width
        let heightOfBottomView = CGRectGetHeight(self.view.frame) - yOriginOfBottomView
        self.bottomView!.frame = CGRectMake(0, yOriginOfBottomView, width, heightOfBottomView)
        self.cropBox!.frame = CGRectMake(0, CGRectGetMaxY(self.topView!.frame), width, width)
        self.imagePreview!.frame = self.view.bounds
        self.captureVideoPreviewLayer!.frame = self.imagePreview!.bounds
        let cameraToolbarHeight = 100
        self.cameraToolbar!.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - CGFloat(cameraToolbarHeight), width, CGFloat(cameraToolbarHeight))
    }
    
    // MARK: - Event Handling
    
    func cancelPressed(sender: UIBarButtonItem) {
        self.delegate!.cameraViewController!(self, didCompleteWithImage: nil)
    }
    
    // MARK: - UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        self.delegate!.cameraViewController!(self, didCompleteWithImage: nil)
    }
    
    // MARK: - CameraToolbarDelegate
    
    func leftButtonPressedOnToolbar(toolbar: CameraToolbar) {
        let currentCameraInput = self.session?.inputs!.first as! AVCaptureDeviceInput
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as! [AVCaptureDevice]
        if (devices.count > 1) {
            var currentIndex = find(devices, currentCameraInput.device)
            var newIndex = 0
            if (currentIndex < devices.count - 1) {
                newIndex = currentIndex! + 1
            }
            let newCamera = devices[newIndex]
            let newVideoInput = AVCaptureDeviceInput(device: newCamera, error: nil)
            if (newVideoInput != nil) {
                let fakeView = self.imagePreview!.snapshotViewAfterScreenUpdates(true)
                fakeView.frame = self.imagePreview!.frame
                self.view.insertSubview(fakeView, aboveSubview: self.imagePreview!)
                self.session!.beginConfiguration()
                self.session!.removeInput(currentCameraInput)
                self.session!.addInput(newVideoInput)
                self.session!.commitConfiguration()
                UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    fakeView.alpha = 0
                }, completion: { (finished: Bool) in
                    fakeView.removeFromSuperview()
                })
            }
        }
    }
    
    func rightButtonPressedOnToolbar(toolbar: CameraToolbar) {
        var imageLibraryVC = ImageLibraryViewController()
        imageLibraryVC.delegate = self;
        self.navigationController!.pushViewController(imageLibraryVC, animated: true)
    }
    
    func cameraButtonPressedOnToolbar(toolbar: CameraToolbar) {
        //self.pressedCameraButton = true
        var videoConnection: AVCaptureConnection?
        for connection in self.stillImageOutput!.connections as! [AVCaptureConnection] {
            for port in connection.inputPorts as! [AVCaptureInputPort] {
                if port.mediaType.isEqual(AVMediaTypeVideo) {
                    videoConnection = connection
                    break
                }
            }
            if (videoConnection != nil) { break }
        }
        self.stillImageOutput!.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (imageSampleBuffer: CMSampleBuffer!, error: NSError!) in
            if (imageSampleBuffer != nil) {
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                var image = UIImage(data: imageData, scale: UIScreen.mainScreen().scale)
                image = image!.imageWithFixedOrientation()
                image = image!.imageResizedToMatchAspectRatioOfSize(self.captureVideoPreviewLayer!.bounds.size)
                let gridRect = self.cropBox!.frame
                var cropRect = gridRect
                cropRect.origin.x = (CGRectGetMinX(gridRect) + (image!.size.width - CGRectGetWidth(gridRect)) / 2);
                image = image!.imageCroppedToRect(cropRect)
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate!.cameraViewController!(self, didCompleteWithImage: image)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertView(title: error.localizedDescription, message: error.localizedRecoverySuggestion, delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "OK button"))
                    alert.show()
                }
            }
        })
    }
    
    // MARK: - ImageLibraryViewControllerDelegate
    
    func imageLibraryViewController(imageLibraryViewController: ImageLibraryViewController, didCompleteWithImage image: UIImage) {
        self.delegate!.cameraViewController!(self, didCompleteWithImage: image)
    }
}
