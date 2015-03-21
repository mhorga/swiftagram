//
//  Media.swift
//  Swiftagram
//
//  Created by Marius Horga on 3/13/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit

class Media: NSObject {

    var idNumber = ""
    var user: User?
    var mediaURL: NSURL?
    var image: UIImage?
    var caption = ""
    var comments = [Comment]()
    
    init(mediaDictionary: NSDictionary) {
        super.init()
        idNumber = mediaDictionary.valueForKey("id") as String
        user = User(userDictionary: mediaDictionary.valueForKey("user") as NSDictionary)
        //let standardResolutionImageURLString = ((((mediaDictionary["images"] as? [NSObject : AnyObject]) ?? [NSObject : AnyObject]())["standard_resolution"] as? [NSObject : AnyObject]) ?? [NSObject : AnyObject]())["url"] as? [NSObject : AnyObject]
        //
        // or we can use valueForKeyPath but it could crash if standard_resolution does not exist, for example
        if let standardResolutionImageURLString  = mediaDictionary.valueForKeyPath("images.standard_resolution.url") as? String {
            let standardResolutionImageURL = NSURL(string: standardResolutionImageURLString)
            if standardResolutionImageURL != nil {
                self.mediaURL = standardResolutionImageURL
            }
        }
        let captionDictionary = mediaDictionary["caption"] as NSDictionary
        if captionDictionary.isKindOfClass(NSDictionary) {
            self.caption = captionDictionary["text"] as String
        } else {
            self.caption = ""
        }
        var commentsArray = [Comment]()
        for (key, commentDictionary) in (mediaDictionary.valueForKeyPath("comments.data") as NSDictionary) {
            let comment = Comment(commentDictionary: commentDictionary as NSDictionary)
            commentsArray.append(comment)
        }
        comments = commentsArray
    }
}
