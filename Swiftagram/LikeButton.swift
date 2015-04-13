//
//  LikeButton.swift
//  Swiftagram
//
//  Created by Marius Horga on 4/7/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit

class LikeButton: UIButton {
    
    enum LikeState: Int {
        case LikeStateNotLiked = 0
        case LikeStateLiking   = 1
        case LikeStateLiked    = 2
        case LikeStateUnliking = 3
    }
    
    /**
    The current state of the like button. Setting to BLCLikeButtonNotLiked or BLCLikeButtonLiked will display an empty heart or a heart, respectively. Setting to BLCLikeButtonLiking or BLCLikeButtonUnliking will display an activity indicator and disable button taps until the button is set to BLCLikeButtonNotLiked or BLCLikeButtonLiked.
    */
    var likeButtonState: LikeState?
    let kLikedStateImage = "heart-full"
    let kUnlikedStateImage = "heart-empty"
    var spinnerView: CircleSpinnerView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.spinnerView = CircleSpinnerView(frame: CGRectMake(0, 0, 44, 44))
        self.addSubview(self.spinnerView!)
        self.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        self.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        self.contentVerticalAlignment = UIControlContentVerticalAlignment.Top
        self.likeButtonState = LikeState.LikeStateNotLiked
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.spinnerView!.frame = self.imageView!.frame
    }
    
    func setLikeButtonState(likeState: LikeState) {
        self.likeButtonState = likeState
        var imageName: NSString?
        switch self.likeButtonState! {
            case .LikeStateLiked, .LikeStateUnliking:
                imageName = kLikedStateImage
            case .LikeStateNotLiked, .LikeStateLiking:
                imageName = kUnlikedStateImage
        }
        switch self.likeButtonState! {
            case .LikeStateLiking, .LikeStateUnliking:
                self.spinnerView!.hidden = false
                self.userInteractionEnabled = false
            case .LikeStateLiked, .LikeStateNotLiked:
                self.spinnerView!.hidden = true
                self.userInteractionEnabled = true
        }
        //self.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
    }
}
