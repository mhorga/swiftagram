//
//  User.swift
//  Swiftagram
//
//  Created by Marius Horga on 3/13/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit

class User: NSObject {

    var idNumber = ""
    var userName = ""
    var fullName = ""
    var profilePictureURL: NSURL?
    var profilePicture: UIImage?
    
    init(userDictionary: NSDictionary) {
        super.init()
        idNumber = userDictionary["id"] as! String
        userName = userDictionary["username"] as! String
        fullName = userDictionary["full_name"] as! String
        let profileURLString = userDictionary["profile_picture"] as! String
        let profileURL = NSURL(string: profileURLString)
        if profileURL != nil {
            profilePictureURL = profileURL
        }
    }
    
    // MARK: - NSCoding
    
    init(aDecoder: NSCoder) {
        super.init()
        self.idNumber = aDecoder.decodeObjectForKey(NSStringFromSelector("id")) as! String
        self.userName = aDecoder.decodeObjectForKey(NSStringFromSelector("userName")) as! String
        self.fullName = aDecoder.decodeObjectForKey(NSStringFromSelector("fullName")) as! String
        self.profilePicture = aDecoder.decodeObjectForKey(NSStringFromSelector("profilePicture")) as? UIImage
        self.profilePictureURL = aDecoder.decodeObjectForKey(NSStringFromSelector("profilePictureURL")) as? NSURL
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.idNumber, forKey: NSStringFromSelector("idNumber"))
        aCoder.encodeObject(self.userName, forKey: NSStringFromSelector("userName"))
        aCoder.encodeObject(self.fullName, forKey: NSStringFromSelector("fullName"))
        aCoder.encodeObject(self.profilePicture, forKey: NSStringFromSelector("profilePicture"))
        aCoder.encodeObject(self.profilePictureURL, forKey: NSStringFromSelector("profilePictureURL"))
    }
}
