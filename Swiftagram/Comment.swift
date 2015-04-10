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
        idNumber = commentDictionary["id"] as! String
        text = commentDictionary["text"] as! String
        from = User(userDictionary: commentDictionary.valueForKey("from") as! NSDictionary)
    }
    
    // MARK: - NSCoding
    
    required init(aDecoder: NSCoder) {
        self.idNumber = aDecoder.decodeObjectForKey(NSStringFromSelector("idNumber")) as! String
        self.text = aDecoder.decodeObjectForKey(NSStringFromSelector("text")) as! String
        self.from = aDecoder.decodeObjectForKey(NSStringFromSelector("from")) as? User
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.idNumber, forKey: NSStringFromSelector("idNumber"))
        aCoder.encodeObject(self.text, forKey: NSStringFromSelector("text"))
        aCoder.encodeObject(self.from, forKey: NSStringFromSelector("from"))
    }
}
