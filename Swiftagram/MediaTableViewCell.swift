//
//  MediaTableViewCell.swift
//  Swiftagram
//
//  Created by Marius Horga on 3/14/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit

class MediaTableViewCell: UITableViewCell {

    var mediaItem: Media? {
        didSet {
            mediaImageView!.image = self.mediaItem!.image
//            usernameAndCaptionLabel!.attributedText = usernameAndCaptionString()
//            commentLabel!.attributedText = commentString()
//            if self.mediaItem!.image != nil {
//                imageHeightConstraint!.constant = self.mediaItem!.image!.size.height / self.mediaItem!.image!.size.width * CGRectGetWidth(contentView.bounds)
//            } else {
//                imageHeightConstraint!.constant = 0
//            }
        }
    }
    
    var usernameAndCaptionLabel: UILabel?
    var commentLabel: UILabel?
    var imageHeightConstraint: NSLayoutConstraint?
    var usernameAndCaptionLabelHeightConstraint: NSLayoutConstraint?
    var commentLabelHeightConstraint: NSLayoutConstraint?
    var lightFont: UIFont?
    var boldFont: UIFont?
    var usernameLabelGray: UIColor?
    var commentLabelGray: UIColor?
    var linkColor: UIColor?
    var paragraphStyle: NSParagraphStyle?
    
    @IBOutlet weak var mediaImageView: UIImageView!
    
    func load() {
        lightFont = UIFont(name: "HelveticaNeue-Thin", size: 11)
        boldFont = UIFont(name: "HelveticaNeue-Bold", size: 11)
        usernameLabelGray = UIColor(red: 0.933, green: 0.933, blue: 0.933, alpha: 1) /*#eeeeee*/
        commentLabelGray = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1) /*#e5e5e5*/
        linkColor = UIColor(red: 0.345, green: 0.314, blue: 0.427, alpha: 1) /*#58506d*/
        var mutableParagraphStyle = NSMutableParagraphStyle()
        mutableParagraphStyle.headIndent = 20.0
        mutableParagraphStyle.firstLineHeadIndent = 20.0
        mutableParagraphStyle.tailIndent = -20.0
        mutableParagraphStyle.paragraphSpacingBefore = 5
        paragraphStyle = mutableParagraphStyle
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setHighlighted(highlighted: Bool, animated : Bool) {
        super.setHighlighted(highlighted, animated: animated)
    }
    
    func usernameAndCaptionString() -> NSAttributedString {
        let usernameFontSize: CGFloat = 15
        let baseString = "\(mediaItem!.user!.userName) \(mediaItem!.caption)"
        let mutableUsernameAndCaptionString = NSMutableAttributedString(string: baseString, attributes:{[NSFontAttributeName: self.lightFont!.fontWithSize(usernameFontSize)]}()) //, NSParagraphStyleAttributeName : paragraphStyle})
        let usernameRange = baseString.rangeOfString(mediaItem!.user!.userName)
        //mutableUsernameAndCaptionString.addAttribute(NSFontAttributeName, value: boldFont.fontWithSize(usernameFontSize), range:usernameRange)
        //mutableUsernameAndCaptionString.addAttribute(NSForegroundColorAttributeName, value:linkColor, range:usernameRange)
        return mutableUsernameAndCaptionString
    }
    
    func commentString() -> NSAttributedString {
        let commentString = NSMutableAttributedString()
        for comment in mediaItem!.comments {
            let baseString = "\(comment.from!.userName) \(comment.text)\n"
            //let oneCommentString = NSMutableAttributedString(string: baseString, attributes:{[NSFontAttributeName: self.lightFont, NSParagraphStyleAttributeName : paragraphStyle]}())
            let usernameRange = baseString.rangeOfString(comment.from!.userName)
            //oneCommentString.addAttribute(NSFontAttributeName, value:boldFont, range:usernameRange)
            //oneCommentString.addAttribute(NSForegroundColorAttributeName, value:linkColor, range:usernameRange)
            //commentString.appendAttributedString(oneCommentString)
        }
        return commentString
    }
    
    func heightForMediaItem(mediaItem: Media, width: CGFloat) -> CGFloat {
        var layoutCell = MediaTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "layoutCell")
        layoutCell.mediaItem = mediaItem
        layoutCell.frame = CGRectMake(0, 0, width, CGRectGetHeight(layoutCell.frame))
        layoutCell.setNeedsLayout()
        layoutCell.layoutIfNeeded()
        return CGRectGetMaxY(layoutCell.commentLabel!.frame)
    }
}
