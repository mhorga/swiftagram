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
    
    init (userDictionary: NSDictionary) {
        super.init()
        idNumber = userDictionary["id"] as String
        userName = userDictionary["username"] as String
        fullName = userDictionary["full_name"] as String
        let profileURLString: AnyObject = userDictionary["profile_picture"]!
        let profileURL = NSURL(coder: profileURLString as NSCoder)
        profilePictureURL = profileURL
    }
}
