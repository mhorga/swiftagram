//
//  Comment.swift
//  Swiftagram
//
//  Created by Marius Horga on 3/13/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit

class Comment: NSObject {

    var idNumber = ""
    var from: User?
    var text = ""
    
    init (commentDictionary: NSDictionary) {
        super.init()
        idNumber = commentDictionary["id"] as String
        text = commentDictionary["text"] as String
        from = User(userDictionary: commentDictionary.valueForKey("from") as NSDictionary)
    }
}
