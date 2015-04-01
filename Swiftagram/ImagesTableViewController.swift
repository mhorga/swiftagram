//
//  ImagesTableViewController.swift
//  Swiftagram
//
//  Created by Marius Horga on 3/14/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit

class ImagesTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataSource.sharedInstance.addObserver(self, forKeyPath: "mediaItems", options: nil, context: nil)
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refreshControlDidFire:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func refreshControlDidFire(sender: UIRefreshControl) {
        DataSource.sharedInstance.requestNewItemsWithCompletionHandler({ (error: NSErrorPointer?) in
            sender.endRefreshing()
        })
    }
    
    deinit {
        DataSource.sharedInstance.removeObserver(self, forKeyPath:"mediaItems")
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let media = item()[indexPath.row] as Media
        if media.image != nil {
            return 350
        } else {
            return 150
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject: AnyObject], context: UnsafeMutablePointer<Void>) {
        if (object as NSObject == DataSource.sharedInstance && keyPath.isEqual("mediaItems")) {
            let kindOfChange = change[NSKeyValueChangeKindKey]?.integerValue
            if kindOfChange == 1 {    // 1 is NSKeyValueChangeSetting in the NSKeyValueChange enum
                tableView.reloadData()
            } else {
                let indexSetOfChanges = change[NSKeyValueChangeIndexesKey] as NSIndexSet
                var indexPathsThatChanged = NSMutableArray()
                indexSetOfChanges.enumerateIndexesUsingBlock( { (idx: NSInteger, stop: UnsafeMutablePointer<ObjCBool>) in
                    let newIndexPath = NSIndexPath(forRow: idx, inSection: 0)
                    indexPathsThatChanged.addObject(newIndexPath)
                })
                tableView.beginUpdates()
                if kindOfChange == 2 {    // 2 is NSKeyValueChangeInsertion in the NSKeyValueChange enum
                    tableView.insertRowsAtIndexPaths(indexPathsThatChanged, withRowAnimation:UITableViewRowAnimation.Automatic)
                } else if kindOfChange == 3 { // 3 is NSKeyValueChangeRemoval in the NSKeyValueChange enum
                    tableView.deleteRowsAtIndexPaths(indexPathsThatChanged, withRowAnimation:UITableViewRowAnimation.Automatic)
                } else if kindOfChange == 4 { // 4 is NSKeyValueChangeReplacement in the NSKeyValueChange enum
                    tableView.reloadRowsAtIndexPaths(indexPathsThatChanged, withRowAnimation:UITableViewRowAnimation.Automatic)
                }
                tableView.endUpdates()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    func item() -> NSArray {
        return DataSource.sharedInstance.mediaItems
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: NSInteger) -> NSInteger {
        return item().count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> MediaTableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("mediaCell", forIndexPath: indexPath) as MediaTableViewCell
        cell.mediaItem = item()[indexPath.row] as? Media
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let media = item()[indexPath.row] as Media
        return 320
        //return MediaTableViewCell.heightForMediaItem(mediaItem: media, width:view.frame.width)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let media = item()[indexPath.row] as Media
            DataSource.sharedInstance.deleteMediaItem(media)
        }
    }
    
    func infiniteScrollIfNecessary() {
        let bottomIndexPath = tableView.indexPathsForVisibleRows()?.last as NSIndexPath
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
}
