//
//  UIImageUtilities.swift
//  Swiftagram
//
//  Created by Marius Horga on 4/7/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import Foundation

extension UIImage {
    
    func imageWithFixedOrientation() -> UIImage {
        if self.imageOrientation == .Up {
            return self
        }
        var transform = CGAffineTransformIdentity
        switch (self.imageOrientation) {
            case .Down, .DownMirrored:
                transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height)
                transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
                break
            case .Left, .LeftMirrored:
                transform = CGAffineTransformTranslate(transform, self.size.width, 0)
                transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
                break
            case .Right, .RightMirrored:
                transform = CGAffineTransformTranslate(transform, 0, self.size.height)
                transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
                break
            case .Up, .UpMirrored:
                break
        }
        switch (self.imageOrientation) {
            case .UpMirrored, .DownMirrored:
                transform = CGAffineTransformTranslate(transform, self.size.width, 0)
                transform = CGAffineTransformScale(transform, -1, 1)
                break
            case .LeftMirrored, .RightMirrored:
                transform = CGAffineTransformTranslate(transform, self.size.height, 0)
                transform = CGAffineTransformScale(transform, -1, 1)
                break
            case .Up, .Down, .Left, .Right:
                break
        }
        let scaleFactor = self.scale
        var ctx = CGBitmapContextCreate(nil, Int(self.size.width * scaleFactor), Int(self.size.height * scaleFactor), CGImageGetBitsPerComponent(self.CGImage), 0, CGImageGetColorSpace(self.CGImage), CGImageGetBitmapInfo(self.CGImage))
        CGContextScaleCTM(ctx, scaleFactor, scaleFactor)
        CGContextConcatCTM(ctx, transform)
        switch (self.imageOrientation) {
            case .Left, .LeftMirrored, .Right, .RightMirrored:
                CGContextDrawImage(ctx, CGRectMake(0,0, self.size.height, self.size.width), self.CGImage)
                break
            default:
                CGContextDrawImage(ctx, CGRectMake(0,0, self.size.width, self.size.height), self.CGImage)
                break
        }
        let cgimg = CGBitmapContextCreateImage(ctx)
        let img = UIImage(CGImage: cgimg, scale: scaleFactor, orientation: .Up)
        return img!
    }
    
    func imageResizedToMatchAspectRatioOfSize(size: CGSize) -> UIImage {
        let horizontalRatio = size.width / self.size.width
        let verticalRatio = size.height / self.size.height
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSizeMake(self.size.width * ratio * self.scale, self.size.height * ratio * self.scale)
        let newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height))
        let imageRef = self.CGImage as CGImageRef
        let ctx = CGBitmapContextCreate(nil, Int(newRect.size.width), Int(newRect.size.height), CGImageGetBitsPerComponent(self.CGImage), 0, CGImageGetColorSpace(self.CGImage), CGImageGetBitmapInfo(self.CGImage))
        CGContextDrawImage(ctx, newRect, imageRef)
        let newImageRef = CGBitmapContextCreateImage(ctx)
        let newImage = UIImage(CGImage: newImageRef, scale: self.scale, orientation: .Up)
        return newImage!
    }
    
    func imageCroppedToRect(cropRect: CGRect) -> UIImage {
        let width = cropRect.size.width * self.scale
        let height = cropRect.size.height * self.scale
        let x = cropRect.origin.x * self.scale
        let y = cropRect.origin.y * self.scale
        let newRect = CGRect(x: x, y: y, width: width, height: height)
        let imageRef = CGImageCreateWithImageInRect(self.CGImage, newRect)
        let image = UIImage(CGImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        return image!
    }
}
