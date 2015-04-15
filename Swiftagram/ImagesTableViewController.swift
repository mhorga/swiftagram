//
//  ImagesTableViewController.swift
//  Swiftagram
//
//  Created by Marius Horga on 3/14/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit

class ImagesTableViewController: UITableViewController, UIViewControllerTransitioningDelegate, CameraViewControllerDelegate, ImageLibraryViewControllerDelegate, MediaTableViewCellDelegate {
    
    var lastTappedImageView: UIImageView?
    var lastSelectedCommentView: UIView?
    var lastKeyboardAdjustment: CGFloat?
    var cameraPopover: UIPopoverController?
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataSource.sharedInstance.addObserver(self, forKeyPath: "mediaItems", options: nil, context: nil)
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refreshControlDidFire:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.registerClass(MediaTableViewCell.self, forCellReuseIdentifier: "mediaCell")
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.Interactive
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) || UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
                let cameraButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Camera, target: self, action: "cameraPressed:")
                self.navigationItem.rightBarButtonItem = cameraButton
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide", name:UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "imageDidFinish", name: ImageFinishedNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        let indexPath = self.tableView.indexPathForSelectedRow()
        if indexPath != nil {
            self.tableView.deselectRowAtIndexPath(indexPath!, animated: animated)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
    }
    
    deinit {
        DataSource.sharedInstance.removeObserver(self, forKeyPath:"mediaItems")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Camera, CameraViewControllerDelegate and ImageLibraryViewControllerDelegate
    
    func isPhone() -> Bool {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            return true
        } else {
            return false
        }
    }
    
    func cameraPressed(sender: UIBarButtonItem) {
        var imageVC: UIViewController?
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            var cameraVC = CameraViewController()
            cameraVC.delegate = self
            imageVC = cameraVC
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            var imageLibraryVC = ImageLibraryViewController()
            imageLibraryVC.delegate = self
            imageVC = imageLibraryVC
        }
        if imageVC != nil {
            let nav = UINavigationController(rootViewController: imageVC!)
            if isPhone() {
                self.presentViewController(nav, animated:true, completion: nil)
            } else {
                self.cameraPopover = UIPopoverController(contentViewController:  nav)
                self.cameraPopover!.popoverContentSize = CGSizeMake(320, 568)
                self.cameraPopover!.presentPopoverFromBarButtonItem(sender, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            }
        }
    }
    
//    func cameraViewController(_: CameraViewController, didCompleteWithImage image: UIImage?) {
//        self.handleImage(image, withNavigationController: cameraViewController.navigationController!)
//    }
    
    func imageLibraryViewController(imageLibraryViewController: ImageLibraryViewController, didCompleteWithImage image: UIImage) {
        self.handleImage(image, withNavigationController: imageLibraryViewController.navigationController!)
    }
    
    func handleImage(image: UIImage?, withNavigationController nav: UINavigationController) {
        if image != nil {
            let postVC = PostToInstagramViewController(sourceImage: image!)
            nav.pushViewController(postVC, animated: true)
        } else {
            if isPhone() {
                nav.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.cameraPopover!.dismissPopoverAnimated(true)
                self.cameraPopover = nil
            }
        }
    }
    
    // MARK: - Table view data source
    
    func item() -> NSArray {
        return DataSource.sharedInstance.mediaItems
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: NSInteger) -> NSInteger {
        return item().count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> MediaTableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("mediaCell", forIndexPath: indexPath) as! MediaTableViewCell
        cell.mediaItem = item()[indexPath.row] as? Media
        cell.delegate = self
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let media = item()[indexPath.row] as! Media
        return 320
        //return MediaTableViewCell.heightForMediaItem(mediaItem: media, width:view.frame.width)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let media = item()[indexPath.row] as! Media
            DataSource.sharedInstance.deleteMediaItem(media)
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let media = item()[indexPath.row] as! Media
        if media.image != nil {
            return 350
        } else {
            return 150
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject: AnyObject], context: UnsafeMutablePointer<Void>) {
        if (object as! NSObject == DataSource.sharedInstance && keyPath.isEqual("mediaItems")) {
            let kindOfChange = change[NSKeyValueChangeKindKey]?.integerValue
            if kindOfChange == 1 {    // 1 is NSKeyValueChangeSetting in the NSKeyValueChange enum
                tableView.reloadData()
            } else {
                let indexSetOfChanges = change[NSKeyValueChangeIndexesKey] as! NSIndexSet
                var indexPathsThatChanged = NSMutableArray()
                indexSetOfChanges.enumerateIndexesUsingBlock( { (idx: NSInteger, stop: UnsafeMutablePointer<ObjCBool>) in
                    let newIndexPath = NSIndexPath(forRow: idx, inSection: 0)
                    indexPathsThatChanged.addObject(newIndexPath)
                })
                tableView.beginUpdates()
                if kindOfChange == 2 {    // 2 is NSKeyValueChangeInsertion in the NSKeyValueChange enum
                    tableView.insertRowsAtIndexPaths(indexPathsThatChanged as [AnyObject], withRowAnimation:UITableViewRowAnimation.Automatic)
                } else if kindOfChange == 3 { // 3 is NSKeyValueChangeRemoval in the NSKeyValueChange enum
                    tableView.deleteRowsAtIndexPaths(indexPathsThatChanged as [AnyObject], withRowAnimation:UITableViewRowAnimation.Automatic)
                } else if kindOfChange == 4 { // 4 is NSKeyValueChangeReplacement in the NSKeyValueChange enum
                    tableView.reloadRowsAtIndexPaths(indexPathsThatChanged as [AnyObject], withRowAnimation:UITableViewRowAnimation.Automatic)
                }
                tableView.endUpdates()
            }
        }
    }
    
    // MARK: - Getting More Data
    
    func refreshControlDidFire(sender: UIRefreshControl) {
        DataSource.sharedInstance.requestNewItemsWithCompletionHandler({ (error: NSErrorPointer?) in
            sender.endRefreshing()
        })
    }
    
    func infiniteScrollIfNecessary() {
        let bottomIndexPath = tableView.indexPathsForVisibleRows()!.last as! NSIndexPath
        if (bottomIndexPath.row == item().count - 1) {
            DataSource.sharedInstance.requestOldItemsWithCompletionHandler(nil)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    //int counter = 0
    override func scrollViewWillBeginDecelerating(scrollView: UIScrollView) { // called only once per image scrolled
        //- (void)scrollViewDidScroll:(UIScrollView *)scrollView {           // called ~700 times
        //counter++
        //NSLog(@"%d", counter)
        infiniteScrollIfNecessary()
    }
    
    // MARK: - MediaTableViewCellDelegate
    
    func cell(cell: MediaTableViewCell, didTapImageView imageView: UIImageView) {
        self.lastTappedImageView = imageView
        let fullScreenVC = MediaFullScreenViewController(media: cell.mediaItem!)
        if isPhone() {
            fullScreenVC.transitioningDelegate = self
            fullScreenVC.modalPresentationStyle = UIModalPresentationStyle.Custom
        } else {
            fullScreenVC.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        }
        presentViewController(fullScreenVC, animated:true, completion: nil)
    }
        
    func cell(cell: MediaTableViewCell, didLongPressImageView imageView:UIImageView) {
        var itemsToShare = [AnyObject]()
        if count(cell.mediaItem!.caption) > 0 {
            itemsToShare.append(cell.mediaItem!.caption)
        }
        if cell.mediaItem!.image != nil {
            itemsToShare.append(cell.mediaItem!.image!)
        }
        if itemsToShare.count > 0 {
            let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
            presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
    func cellDidPressLikeButton(cell: MediaTableViewCell) {
        DataSource.sharedInstance.toggleLikeOnMediaItem(cell.mediaItem!)
    }
    
    func cellWillStartComposingComment(cell: MediaTableViewCell) {
        self.lastSelectedCommentView = cell.commentView
    }
    
    func cell(cell: MediaTableViewCell, didComposeComment comment: NSString) {
        DataSource.sharedInstance.commentOnMediaItem(cell.mediaItem!, commentText: comment)
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = MediaFullScreenAnimator()
        animator.presenting = true
        animator.cellImageView = self.lastTappedImageView
        return animator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = MediaFullScreenAnimator()
        animator.cellImageView = self.lastTappedImageView
        return animator
    }
    
    // MARK: - Popover Handling
    
    func imageDidFinish(notification: NSNotification) {
        if isPhone() {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            cameraPopover!.dismissPopoverAnimated(true)
            self.cameraPopover = nil
        }
    }
    
    // MARK: - Keyboard Handling
    
    func keyboardWillShow(notification: NSNotification) {
        let frameValue: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardFrameInScreenCoordinates = frameValue.CGRectValue
        let keyboardFrameInViewCoordinates = navigationController!.view.convertRect( keyboardFrameInScreenCoordinates(), fromView: nil)
        let commentViewFrameInViewCoordinates = navigationController!.view.convertRect( lastSelectedCommentView!.bounds, fromView: self.lastSelectedCommentView)
        var contentOffset = self.tableView.contentOffset
        var contentInsets = self.tableView.contentInset
        var scrollIndicatorInsets = self.tableView.scrollIndicatorInsets
        var heightToScroll: CGFloat = 0
        let keyboardY = CGRectGetMinY(keyboardFrameInViewCoordinates)
        let commentViewY = CGRectGetMinY(commentViewFrameInViewCoordinates)
        let difference = commentViewY - keyboardY
        if difference > 0 {
            heightToScroll += difference
        }
        if CGRectIntersectsRect(keyboardFrameInViewCoordinates, commentViewFrameInViewCoordinates) {
            let intersectionRect = CGRectIntersection(keyboardFrameInViewCoordinates, commentViewFrameInViewCoordinates);
            heightToScroll += CGRectGetHeight(intersectionRect);
        }
        if heightToScroll > 0 {
            contentInsets.bottom += heightToScroll
            scrollIndicatorInsets.bottom += heightToScroll
            contentOffset.y += heightToScroll;
            let durationNumber = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
            let curveNumber = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! UIViewAnimationCurve
            let duration = durationNumber.doubleValue as NSTimeInterval
            let curve = curveNumber.rawValue //curveNumber.unsignedIntegerValueas as UIViewAnimationCurve
            let options = curve << 16 //as UIViewAnimationOptions
            UIView.animateWithDuration(duration, delay: 0, options: nil //options
                , animations: {
                self.tableView.contentInset = contentInsets;
                self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
                self.tableView.contentOffset = contentOffset;
            }, completion: nil)
        }
        self.lastKeyboardAdjustment = heightToScroll;
    }
    
    func keyboardWillHide(notification: NSNotification) {
        var contentInsets = self.tableView.contentInset
        contentInsets.bottom -= self.lastKeyboardAdjustment!
        var scrollIndicatorInsets = self.tableView.scrollIndicatorInsets
        scrollIndicatorInsets.bottom -= self.lastKeyboardAdjustment!
        let durationNumber = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let curveNumber = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! UIViewAnimationCurve
        let duration = durationNumber.doubleValue as NSTimeInterval
        let curve = curveNumber.rawValue //curveNumber.unsignedIntegerValueas as UIViewAnimationCurve
        let options = curve << 16 // as UIViewAnimationOptions
        UIView.animateWithDuration(duration, delay: 0, options: nil //options
            , animations: {
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = scrollIndicatorInsets
        }, completion: nil)
    }
}
