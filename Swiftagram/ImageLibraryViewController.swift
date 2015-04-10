//
//  ImageLibraryViewController.swift
//  Swiftagram
//
//  Created by Marius Horga on 4/4/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit
import AssetsLibrary

@objc protocol ImageLibraryViewControllerDelegate {
    
    optional func imageLibraryViewController(imageLibraryViewController: ImageLibraryViewController, didCompleteWithImage image: UIImage)

}

class ImageLibraryViewController: UICollectionViewController, CropImageViewControllerDelegate {

    var delegate: ImageLibraryViewControllerDelegate?
    let library: ALAssetsLibrary?
    var groups: Array<AnyObject>
    var arraysOfAssets: Array<AnyObject>
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(100, 100)
        self.library = ALAssetsLibrary()
        self.groups = [AnyObject]()
        self.arraysOfAssets = [AnyObject]()
        super.init(collectionViewLayout: layout)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "reusable view")
        self.collectionView!.backgroundColor = UIColor.whiteColor()
        let cancelImage = UIImage(named: "x")
        let cancelButton = UIBarButtonItem(image: cancelImage, style:.Done, target: self, action: "cancelPressed")
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let width = CGRectGetWidth(self.view.frame)
        let minWidth = 100
        let divisor = width / CGFloat(minWidth)
        let cellSize = width / divisor
        let flowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSizeMake(cellSize, cellSize)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.headerReferenceSize = CGSizeMake(width, 30)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.groups.removeAll(keepCapacity: true)
        self.arraysOfAssets.removeAll(keepCapacity: true)
        self.library!.enumerateGroupsWithTypes(ALAssetsGroupSavedPhotos | ALAssetsGroupAlbum, usingBlock: { (group: ALAssetsGroup!, stop: UnsafeMutablePointer<ObjCBool>) in
            if group != nil {
                self.groups.append(group)
                var assets = [AnyObject]()
                self.arraysOfAssets.append(assets)
                group.enumerateAssetsUsingBlock() { (result: ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                    if result != nil {
                        assets.append(result)
                    }
                }
                self.collectionView!.reloadData()
            }
        }, failureBlock: { (error: NSError!) in
            let alert = UIAlertView(title: error.localizedDescription, message: error.localizedRecoverySuggestion, delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "OK button"))
            alert.show()
            self.collectionView!.reloadData()
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.groups.removeAll(keepCapacity: true)
        self.arraysOfAssets.removeAll(keepCapacity: true)
        self.collectionView!.reloadData()
    }
    
    func cancelPressed(sender: UIBarButtonItem) {
        self.delegate!.imageLibraryViewController!(self, didCompleteWithImage: sender.image!) //didCompleteWithImage: nil)
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.groups.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let imagesArray = self.arraysOfAssets[section] as! [UICollectionView]
        if (imagesArray != NSNull()) {
            return imagesArray.count
        }
        return 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            let imageViewTag = 54321
            var cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! UICollectionViewCell
            var imageView = cell.contentView.viewWithTag(imageViewTag) as! UIImageView
            if imageView != NSNull() {
            imageView = UIImageView(frame: cell.contentView.bounds)
            imageView.tag = imageViewTag
            imageView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            imageView.clipsToBounds = true
            cell.contentView.addSubview(imageView)
        }
        let asset = self.arraysOfAssets[indexPath.section][indexPath.row] as! ALAsset
        let imageRef = asset.thumbnail().takeRetainedValue() as CGImageRef?
        var image = UIImage()
        if imageRef != nil  {
            image = UIImage(CGImage: imageRef)!
        }
        imageView.image = image
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "reusable view", forIndexPath: indexPath) as! UICollectionReusableView
        if kind.isEqual(UICollectionElementKindSectionHeader) {
            let headerLabelTag = 2468
            var label = view.viewWithTag(headerLabelTag) as! UILabel?
            if label == nil {
                label = UILabel(frame: view.bounds)
                label!.tag = headerLabelTag
                label!.autoresizingMask = .FlexibleHeight | .FlexibleWidth
                label!.textAlignment = NSTextAlignment.Center
                label!.backgroundColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 235/255.0, alpha: 1.0)
                view.addSubview(label!)
            }
            let group = self.groups[indexPath.section] as! ALAssetsGroup
            let textColor = UIColor(white: 0.35, alpha: 1)
            let textAttributes = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : UIFont(name: "HelveticaNeue-Medium", size: 14)!, NSTextEffectAttributeName : NSTextEffectLetterpressStyle] as NSDictionary
            var attributedString = NSAttributedString()
            let groupName = group.valueForProperty(ALAssetsGroupPropertyName) as! NSString?
            if groupName != nil {
                attributedString = NSAttributedString(string: groupName! as String, attributes: textAttributes as [NSObject : AnyObject])
            }
            label!.attributedText = attributedString
        }
        return view
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let asset = self.arraysOfAssets[indexPath.section][indexPath.row] as! ALAsset
        let representation = asset.defaultRepresentation
        let imageRef = representation().fullResolutionImage
        var imageToCrop = UIImage()
//        if (imageRef) {
//            imageToCrop = [UIImage imageWithCGImage:imageRef scale:representation.scale orientation:(UIImageOrientation)representation.orientation];
//        }
        var cropVC = CropImageViewController(sourceImage: imageToCrop)
        cropVC.delegate = self
        self.navigationController!.pushViewController(cropVC, animated:true)
    }
    
    // MARK: - CropImageViewControllerDelegate
    
    func cropControllerFinishedWithImage(croppedImage: UIImage) {
        self.delegate!.imageLibraryViewController!(self, didCompleteWithImage: croppedImage)
    }
}
