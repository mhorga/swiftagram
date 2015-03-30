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
        if let standardResolutionImageURLString  = mediaDictionary.valueForKeyPath("images.standard_resolution.url") as? String {
            let standardResolutionImageURL = NSURL(string: standardResolutionImageURLString)
            if standardResolutionImageURL != nil {
                self.mediaURL = standardResolutionImageURL
            }
        }
        let captionDictionary = mediaDictionary["caption"] as? NSDictionary
        if let captionDictionary = captionDictionary {
            self.caption = captionDictionary["text"] as String
        } else {
            self.caption = ""
        }
        var commentsArray = [Comment]()
        let commentData = mediaDictionary.valueForKeyPath("comments.data") as NSArray?
        if let commentData = commentData {
            for commentDictionary in commentData {
                let comment = Comment(commentDictionary: commentDictionary as NSDictionary)
                commentsArray.append(comment)
            }
        }
        comments = commentsArray
    }
}
