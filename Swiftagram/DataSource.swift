//
//  DataSource.swift
//  Swiftagram
//
//  Created by Marius Horga on 3/13/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit
import KeychainAccess

typealias NewItemCompletionBlock = ((NSErrorPointer?) -> Void)

class DataSource: NSObject {
    
    // only readable from outside but writable from inside
    private(set) internal var mediaItems = [Media]()
    var accessToken: String?
    var isRefreshing: Bool?
    var isLoadingOlderItems: Bool?
    var thereAreNoMoreOlderMessages: Bool?
    let keychain = Keychain()
    
    class var sharedInstance: DataSource {
        struct Singleton {
            static let instance = DataSource()
        }
        return Singleton.instance
    }
    
    func instagramClientID() -> NSString {
        return "e9241ba8d61442b9861ce40d22e1452a"
    }
    
    override init () {
        super.init()
        self.accessToken = self.keychain["access token"]
        if (self.accessToken == nil) {
            registerForAccessTokenNotification()
        } else {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//                let fullPath = self.pathForFilename("mediaItems")
//                let storedMediaItems = NSKeyedUnarchiver.unarchiveObjectWithFile(fullPath) as? [Media]
//                dispatch_async(dispatch_get_main_queue()) {
//                    if (storedMediaItems!.count > 0) {
//                        var mutableMediaItems = storedMediaItems
//                        self.willChangeValueForKey("mediaItems")
//                        self.mediaItems = mutableMediaItems!
//                        self.didChangeValueForKey("mediaItems")
//                    } else {
                        populateDataWithParameters(nil, completionHandler: nil)
//                     }
//                }
//            }
        }
    }
   
    func registerForAccessTokenNotification() {
        NSNotificationCenter.defaultCenter().addObserverForName(LoginViewController().LoginViewControllerDidGetAccessTokenNotification, object: nil, queue: nil, usingBlock: { (note: NSNotification?) in
            self.accessToken = note!.object as? String
            self.keychain.set(self.accessToken!, key:"access token")
            self.populateDataWithParameters(nil, completionHandler: nil)
        })
    }
    
    func populateDataWithParameters(parameters: NSDictionary?, completionHandler: NewItemCompletionBlock?) {
        if accessToken != nil {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                var urlString = "https://api.instagram.com/v1/users/self/feed?access_token=\(self.accessToken!)"
                if let parameters = parameters {
                    for (parameterName, value) in parameters {
                        let paramName = parameterName as String
                        let params = value as String
                        urlString += "&\(paramName)=\(params)"
                    }
                }
                let url = NSURL(string: urlString)
                if url != nil {
                    let request = NSURLRequest(URL: url!)
                    let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil
                    let webError = NSErrorPointer()
                    let responseData: NSData =  NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: webError)!
                    let jsonError = NSErrorPointer()
                    let feedDictionary = NSJSONSerialization.JSONObjectWithData(responseData, options: nil, error: jsonError) as NSDictionary
                    dispatch_async(dispatch_get_main_queue(), {
                        self.parseDataFromFeedDictionary(feedDictionary, parameters: parameters)
                        if completionHandler != nil {
                            completionHandler!(nil)
                        }
                    })
                }
            })
        }
    }
    
    func parseDataFromFeedDictionary(feedDictionary: Dictionary<NSObject, AnyObject>, parameters: NSDictionary?) {
        let mediaArray = feedDictionary["data"] as NSArray
        var tmpMediaItems = [Media]()
        for mediaDictionary in mediaArray {
            let mediaItem = Media(mediaDictionary: mediaDictionary as NSDictionary)
            if (mediaItem != NSNull()) {
                tmpMediaItems.append(mediaItem)
                downloadImageForMediaItem(mediaItem)
            }
        }
        var mutableArrayWithKVO = mutableArrayValueForKey("mediaItems")
        if parameters != nil && parameters!["min_id"] != nil {
            let rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count)
            let indexSetOfNewObjects = NSIndexSet(indexesInRange: rangeOfIndexes)
            mutableArrayWithKVO.insertObjects(tmpMediaItems, atIndexes:indexSetOfNewObjects)
        } else if parameters != nil && parameters!["max_id"] != nil {
            if (tmpMediaItems.count == 0) {
                self.thereAreNoMoreOlderMessages = true
            }
            mutableArrayWithKVO.addObjectsFromArray(tmpMediaItems)
        } else {
            willChangeValueForKey("mediaItems")
            mediaItems = tmpMediaItems
            didChangeValueForKey("mediaItems")
        }
        if (tmpMediaItems.count > 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let numberOfItemsToSave = min(self.mediaItems.count, 50)
                let mediaItemsToSave = self.mediaItems[0 ..< numberOfItemsToSave]
            }
        }
    }
    
    func pathForFilename(filename: NSString) -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        let documentsDirectory: AnyObject? = paths.first
        let dataPath = documentsDirectory!.stringByAppendingPathComponent(filename)
        return dataPath
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
                            let index = find(self.mediaItems, mediaItem)
                            //self.mediaItems.replaceObjectAtIndex(index, withObject: mediaItem)
                            self.mediaItems.removeAtIndex(index!)
                            self.mediaItems.append(mediaItem)
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
