//
//  MediaTableViewCell.swift
//  Swiftagram
//
//  Created by Marius Horga on 3/14/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit

@objc protocol MediaTableViewCellDelegate {
    
    optional func cell(cell: MediaTableViewCell, didTapImageView imageView: UIImageView)
    optional func cell(cell: MediaTableViewCell, didLongPressImageView imageView: UIImageView)
    optional func cellDidPressLikeButton(cell: MediaTableViewCell)
    optional func cellWillStartComposingComment(cell: MediaTableViewCell)
    optional func cell(cell: MediaTableViewCell, didComposeComment comment: NSString)
}

class MediaTableViewCell: UITableViewCell, UIGestureRecognizerDelegate, ComposeCommentViewDelegate {

    var mediaImageView: UIImageView?
    var usernameAndCaptionLabel: UILabel?
    var commentLabel: UILabel?
    var imageHeightConstraint: NSLayoutConstraint?
    var usernameAndCaptionLabelHeightConstraint: NSLayoutConstraint?
    var commentLabelHeightConstraint: NSLayoutConstraint?
    var tapGestureRecognizer: UITapGestureRecognizer?
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    var likeButton: LikeButton?
    var lightFont: UIFont?
    var boldFont: UIFont?
    var usernameLabelGray: UIColor?
    var commentLabelGray: UIColor?
    var linkColor: UIColor?
    var paragraphStyle: NSParagraphStyle?
    var delegate: MediaTableViewCellDelegate?
    var commentView: ComposeCommentView?
    var mediaItem: Media? {
        didSet {
            if self.mediaItem!.image != nil {
                mediaImageView!.image = self.mediaItem!.image
                usernameAndCaptionLabel!.attributedText = usernameAndCaptionString()
                commentLabel!.attributedText = commentString()
                imageHeightConstraint!.constant = self.mediaItem!.image!.size.height / self.mediaItem!.image!.size.width * CGRectGetWidth(contentView.bounds)
            }
            else {
                imageHeightConstraint!.constant = 0
            }
        }
    }

//    func setMediaItem(mediaItem: Media) {
//        self.mediaItem = mediaItem
//        self.mediaImageView!.image = self.mediaItem!.image
//        self.usernameAndCaptionLabel!.attributedText = self.usernameAndCaptionString()
//        self.commentLabel!.attributedText = self.commentString()
//        self.likeButton!.likeButtonState = mediaItem.likeState
//        self.commentView!.text = mediaItem.temporaryComment
//    }
    
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
    
    func heightForMediaItem(mediaItem: Media, width: CGFloat) -> CGFloat {
        var layoutCell = MediaTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "layoutCell")
        layoutCell.mediaItem = mediaItem
        layoutCell.frame = CGRectMake(0, 0, width, CGRectGetHeight(layoutCell.frame))
        layoutCell.setNeedsLayout()
        layoutCell.layoutIfNeeded()
        return CGRectGetMaxY(layoutCell.commentLabel!.frame)
    }

     func initWith(style: UITableViewCellStyle, reuseIdentifier: NSString) {
        //super.initWithStyle(style, reuseIdentifier: reuseIdentifier)
        self.mediaImageView = UIImageView()
        self.mediaImageView!.userInteractionEnabled = true
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapFired")
        self.tapGestureRecognizer!.delegate = self;
        self.mediaImageView!.addGestureRecognizer(self.tapGestureRecognizer!)
        self.longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressFired")
        self.longPressGestureRecognizer!.delegate = self
        self.mediaImageView!.addGestureRecognizer(self.longPressGestureRecognizer!)
        self.usernameAndCaptionLabel = UILabel()
        self.usernameAndCaptionLabel!.numberOfLines = 0
        self.usernameAndCaptionLabel!.backgroundColor = usernameLabelGray
        self.commentLabel = UILabel()
        self.commentLabel!.numberOfLines = 0
        self.commentLabel!.backgroundColor = commentLabelGray
        self.likeButton = LikeButton()
        self.likeButton!.addTarget(self, action: "likePressed", forControlEvents: UIControlEvents.TouchUpInside)
        self.likeButton!.backgroundColor = usernameLabelGray
        self.commentView = ComposeCommentView()
        self.commentView!.delegate = self
        self.contentView.addSubview(self.mediaImageView!)
//        self.mediaImageView.translatesAutoresizingMaskIntoConstraints() = false
        self.contentView.addSubview(self.usernameAndCaptionLabel!)
//        self.usernameAndCaptionLabel.translatesAutoresizingMaskIntoConstraints() = false
        self.contentView.addSubview(self.commentLabel!)
//        self.commentLabel.translatesAutoresizingMaskIntoConstraints() = false
        self.contentView.addSubview(self.likeButton!)
//        self.likeButton.translatesAutoresizingMaskIntoConstraints() = false
        self.contentView.addSubview(self.commentView!)
//        self.commentView.translatesAutoresizingMaskIntoConstraints() = false
        self.createConstraints()
    }
    
    func isPhone() -> Bool {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            return true
        } else {
            return false
        }
    }
    
    func createConstraints() {
        if isPhone() == true {
            self.createPhoneConstraints()
        } else {
            self.createPadConstraints()
        }
        self.createCommonConstraints()
    }
    
    func createPadConstraints() {
        let viewDictionary = ["self.mediaImageView" : self.mediaImageView!, "self.usernameAndCaptionLabel" : self.usernameAndCaptionLabel!, "self.commentLabel" : self.commentLabel!, "self.likeButton" : self.likeButton!, "self.commentView" : self.commentView!]
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[_mediaImageView(==320)]", options: nil, metrics: nil, views: viewDictionary))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation(rawValue: 0)!, toItem: self.mediaImageView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
    }
    
    func createPhoneConstraints() {
        let viewDictionary = ["self.mediaImageView" : self.mediaImageView!, "self.usernameAndCaptionLabel" : self.usernameAndCaptionLabel!, "self.commentLabel" : self.commentLabel!, "self.likeButton" : self.likeButton!, "self.commentView" : self.commentView!]
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[_mediaImageView]|", options: nil, metrics: nil, views: viewDictionary))
    }
    
    func createCommonConstraints() {
        let viewDictionary = ["self.mediaImageView" : self.mediaImageView!, "self.usernameAndCaptionLabel" : self.usernameAndCaptionLabel!, "self.commentLabel" : self.commentLabel!, "self.likeButton" : self.likeButton!, "self.commentView" : self.commentView!]
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[_usernameAndCaptionLabel][_likeButton(==38)]|", options: NSLayoutFormatOptions.AlignAllTop | NSLayoutFormatOptions.AlignAllBottom, metrics: nil, views: viewDictionary))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[_commentLabel]|", options: nil, metrics: nil, views: viewDictionary))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[_commentView]|", options: nil, metrics: nil, views: viewDictionary))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[_mediaImageView][_usernameAndCaptionLabel][_commentLabel][_commentView(==100)]", options: nil, metrics: nil, views: viewDictionary))
        self.imageHeightConstraint = NSLayoutConstraint(item: self.mediaImageView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 100)
        self.usernameAndCaptionLabelHeightConstraint = NSLayoutConstraint(item: self.usernameAndCaptionLabel!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 100)
        self.commentLabelHeightConstraint = NSLayoutConstraint(item: self.commentLabel!, attribute: NSLayoutAttribute.Height, relatedBy:NSLayoutRelation.Equal, toItem: nil, attribute:NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 100)
        self.contentView.addConstraints([self.imageHeightConstraint!, self.usernameAndCaptionLabelHeightConstraint!, self.commentLabelHeightConstraint!])
    }
    
//    - (void)awakeFromNib {}
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setHighlighted(highlighted: Bool, animated : Bool) {
        super.setHighlighted(highlighted, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let maxSize = CGSizeMake(CGRectGetWidth(self.bounds), CGFloat.max)
        let usernameLabelSize = self.usernameAndCaptionLabel!.sizeThatFits(maxSize)
        let commentLabelSize = self.commentLabel!.sizeThatFits(maxSize)
        self.usernameAndCaptionLabelHeightConstraint!.constant = usernameLabelSize.height + 20
        self.commentLabelHeightConstraint!.constant = commentLabelSize.height + 20
        if self.mediaItem!.image != nil {
        if isPhone() == true {
            self.imageHeightConstraint!.constant = self.mediaItem!.image!.size.height / self.mediaItem!.image!.size.width * CGRectGetWidth(self.contentView.bounds)
        } else {
            self.imageHeightConstraint!.constant = 320
        }
        } else {
            self.imageHeightConstraint!.constant = 0
        }
        self.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(self.bounds))
    }
    
    // MARK: - Liking
    
    func likePressed(sender: UIButton) {
        self.delegate!.cellDidPressLikeButton!(self)
    }
    
    // MARK: - Image View
    
    func tapFired(sender: UITapGestureRecognizer) {
        self.delegate!.cell!(self, didTapImageView: self.mediaImageView!)
    }
    
    func longPressFired(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            self.delegate!.cell!(self, didLongPressImageView: self.mediaImageView!)
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return false //return self.isEditing == false
    }
    
    // MARK: - BLCComposeCommentViewDelegate
    
    func commentViewDidPressCommentButton(sender: ComposeCommentView) {
        self.delegate!.cell!(self, didComposeComment: self.mediaItem!.temporaryComment)
    }
    
    func commentView(sender: ComposeCommentView, textDidChange text: NSString) {
        self.mediaItem!.temporaryComment = text as String
    }
    
    func commentViewWillStartEditing(sender: ComposeCommentView) {
        self.delegate!.cellWillStartComposingComment!(self)
    }
    
    func stopComposingComment() {
        self.commentView!.stopComposingComment()
    }
    
    // MARK: - Attributed Strings
    
    func usernameAndCaptionString() -> NSAttributedString {
        let usernameFontSize: CGFloat = 15
        let baseString: NSString = "\(mediaItem!.user!.userName) \(mediaItem!.caption)"
        let mutableUsernameAndCaptionString = NSMutableAttributedString(string: baseString as String, attributes: [NSFontAttributeName: self.lightFont!.fontWithSize(usernameFontSize), NSParagraphStyleAttributeName : paragraphStyle!])
        let usernameRange = baseString.rangeOfString(mediaItem!.user!.userName)
        mutableUsernameAndCaptionString.addAttribute(NSFontAttributeName, value: boldFont!.fontWithSize(usernameFontSize), range: usernameRange)
        mutableUsernameAndCaptionString.addAttribute(NSForegroundColorAttributeName, value: linkColor!, range: usernameRange)
        return mutableUsernameAndCaptionString
    }
    
    func commentString() -> NSAttributedString {
        let commentString = NSMutableAttributedString()
        for comment in mediaItem!.comments {
            let baseString: NSString = "\(comment.from!.userName) \(comment.text)\n"
            let oneCommentString = NSMutableAttributedString(string: baseString as String, attributes: [NSFontAttributeName: self.lightFont!, NSParagraphStyleAttributeName : paragraphStyle!])
            let usernameRange = baseString.rangeOfString(comment.from!.userName)
            oneCommentString.addAttribute(NSFontAttributeName, value:boldFont!, range:usernameRange)
            oneCommentString.addAttribute(NSForegroundColorAttributeName, value:linkColor!, range:usernameRange)
            commentString.appendAttributedString(oneCommentString)
        }
        return commentString
    }
}
