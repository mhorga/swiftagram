//
//  DataSource.swift
//  Swiftagram
//
//  Created by Marius Horga on 3/13/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit

typealias NewItemCompletionBlock = ((NSErrorPointer?) -> Void)

class DataSource: NSObject {
    // only readable from outside but writable from inside
    private(set) internal var mediaItems = [Media]()
    var accessToken: String?
    var isRefreshing: Bool?
    var isLoadingOlderItems: Bool?
    var thereAreNoMoreOlderMessages: Bool?
    
    class var sharedInstance: DataSource {
        struct Singleton {
            static let instance = DataSource()
        }
        return Singleton.instance
    }
    
    func instagramClientID() -> NSString {
        return ""
    }
    
    override init () {
        super.init()
        registerForAccessTokenNotification()
    }
   
    func registerForAccessTokenNotification() {
        NSNotificationCenter.defaultCenter().addObserverForName(LoginViewController().LoginViewControllerDidGetAccessTokenNotification, object: nil, queue: nil, usingBlock: { (note: NSNotification?) in
            self.accessToken = note!.object as? String
            self.populateDataWithParameters(nil, completionHandler: nil)
        })
    }
    
    func populateDataWithParameters(parameters: NSDictionary?, completionHandler: NewItemCompletionBlock?) {
        if let parameters = parameters {
            if accessToken != nil {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                    var urlString = "https://api.instagram.com/v1/users/self/feed?access_token=\(self.accessToken)"
                    for (parameterName, value) in parameters {
                        let paramName = parameterName as String
                        let params = value as String
                        urlString += "&\(paramName)=\(params)"
                    }
                    let url = NSURL(string: urlString)
                    if url != nil {
                        let request = NSURLRequest(URL: url!)
                        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil
                        let webError = NSErrorPointer()
                        let responseData: NSData =  NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: webError)!
                        if responseData != NSNull() {
                            let jsonError = NSErrorPointer()
                            let feedDictionary = NSJSONSerialization.JSONObjectWithData(responseData, options: nil, error: jsonError) as NSDictionary
                            if feedDictionary != NSNull() {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.parseDataFromFeedDictionary(feedDictionary, parameters: parameters)
                                    if completionHandler != nil {
                                        completionHandler!(nil)
                                    }
                                })
                            } else if (completionHandler != nil) {
                                dispatch_async(dispatch_get_main_queue(), {
                                    completionHandler!(jsonError)
                                })
                            }
                        } else if (completionHandler != nil) {
                            dispatch_async(dispatch_get_main_queue(), {
                                completionHandler!(webError)
                            })
                        }
                    }
                })
            }
        }
    }
    
    func parseDataFromFeedDictionary(feedDictionary: NSDictionary, parameters: NSDictionary) {
        let mediaArray = feedDictionary["data"] as NSDictionary
        var tmpMediaItems = [Media]()
        for (index, mediaDictionary) in mediaArray as NSDictionary {
            let mediaItem = Media(mediaDictionary: mediaDictionary as NSDictionary)
            if (mediaItem != NSNull()) {
                tmpMediaItems.append(mediaItem)
                downloadImageForMediaItem(mediaItem)
            }
        }
        var mutableArrayWithKVO = mutableArrayValueForKey("mediaItems")
        if parameters["min_id"] != nil {
            let rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count)
            let indexSetOfNewObjects = NSIndexSet(indexesInRange: rangeOfIndexes)
            mutableArrayWithKVO.insertObjects(tmpMediaItems, atIndexes:indexSetOfNewObjects)
        } else if parameters["max_id"] != nil {
            if (tmpMediaItems.count == 0) {
                self.thereAreNoMoreOlderMessages = true
            }
            mutableArrayWithKVO.addObjectsFromArray(tmpMediaItems)
        } else {
            willChangeValueForKey("mediaItems")
            mediaItems = tmpMediaItems
            didChangeValueForKey("mediaItems")
        }
    }
    
    func downloadImageForMediaItem(mediaItem: Media) {
        if mediaItem.mediaURL != nil && mediaItem.image == nil {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let request = NSURLRequest(URL: mediaItem.mediaURL!)
                var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil
                var error: NSErrorPointer = nil
                var imageData: NSData =  NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)!
                if imageData != NSNull() {
                    let image = UIImage(data: imageData)
                    if image != nil {
                        mediaItem.image = image
                        dispatch_async(dispatch_get_main_queue(), {
                            var mutableArrayWithKVO = NSMutableArray().valueForKey("mediaItems") as NSMutableArray
                            let index = mutableArrayWithKVO.indexOfObject(mediaItem)
                            mutableArrayWithKVO.replaceObjectAtIndex(index, withObject: mediaItem)
                        })
                    }
                } else {
                    println("Error downloading image: \(error)")
                }
            })
        }
    }
    
    func requestNewItemsWithCompletionHandler(completionHandler: NewItemCompletionBlock?) {
        thereAreNoMoreOlderMessages = false
        if (isRefreshing == false) {
            isRefreshing = true
            let minID = mediaItems.first?.idNumber
            let parameters: Dictionary<String, AnyObject!> = ["min_id" : minID]
            populateDataWithParameters(parameters, completionHandler: { (error: NSErrorPointer?) in
                self.isRefreshing = false
                if completionHandler != nil {
                    completionHandler!(error)
                }
            })
        }
    }
    
    func requestOldItemsWithCompletionHandler(completionHandler: NewItemCompletionBlock?) {
        if (isLoadingOlderItems == false && thereAreNoMoreOlderMessages == false) {
            isLoadingOlderItems = true
            let maxID = mediaItems.last?.idNumber
            var parameters: Dictionary<String, AnyObject!> = ["max_id": maxID]
            isLoadingOlderItems = false
            if completionHandler != nil {
                completionHandler!(nil)
            }
            populateDataWithParameters(parameters, completionHandler: { (error: NSErrorPointer?) in
                self.isLoadingOlderItems = false
                if completionHandler != nil {
                    completionHandler!(error)
                }
            })
        }
    }
    
    // #MARK: - Key/Value Observing
    
    func countOfMediaItems() -> NSInteger {
        return mediaItems.count
    }
    
    func objectInMediaItemsAtIndex(index: NSInteger) -> (AnyObject) {
        return mediaItems[index]
    }
    
    func mediaItemsAtIndexes(indexes: NSIndexSet) -> (NSArray) {
        let tempArray = mediaItems as NSArray
        return tempArray.objectsAtIndexes(indexes)
    }
    
    func insertObject(object: Media, inMediaItemsAtIndex index: NSInteger) {
        mediaItems.insert(object, atIndex: index)
    }
    
    func removeObjectFromMediaItemsAtIndex(index: NSInteger) {
        mediaItems.removeAtIndex(index)
    }
    
    func replaceObjectInMediaItemsAtIndex(index: NSInteger, withObject object: (AnyObject)) {
        mediaItems.removeAtIndex(index)
        mediaItems.insert(object as (Media), atIndex: index)
    }
    
    func deleteMediaItem(item: Media) {
        var mutableArrayWithKVO = mutableArrayValueForKey("mediaItems")
        mutableArrayWithKVO.removeObject(item)
    }
}
