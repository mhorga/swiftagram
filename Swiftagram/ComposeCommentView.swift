//
//  ComposeCommentView.swift
//  Swiftagram
//
//  Created by Marius Horga on 4/6/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit

@objc protocol ComposeCommentViewDelegate {
    
    optional func commentViewDidPressCommentButton(sender: ComposeCommentView)
    optional func commentView(sender: ComposeCommentView, textDidChange text: NSString)
    optional func commentViewWillStartEditing(sender: ComposeCommentView)

}

class ComposeCommentView: UIView, UITextViewDelegate {

    var delegate: ComposeCommentViewDelegate?
    var isWritingComment: Bool?
    var text = ""
    let textView: UITextView?
    let button: UIButton?
    
    override init(frame: CGRect) {
        self.textView = UITextView()
        self.button = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        super.init(frame: frame)
        self.button!.addTarget(self, action: "commentButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.textView!.addSubview(self.button!)
        self.textView!.delegate = self
        self.button!.setAttributedTitle(self.commentAttributedString(), forState: UIControlState.Normal)
        self.addSubview(self.textView!)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func commentAttributedString() -> NSAttributedString {
        let baseString = NSLocalizedString("COMMENT", comment: "comment button text") as NSString
        let range = baseString.rangeOfString(baseString as String)
        var commentString = NSMutableAttributedString(string: baseString as String)
        commentString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Bold", size: 10)!, range: range)
        commentString.addAttribute(NSKernAttributeName, value: 1.3, range: range)
        commentString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 0.933, green: 0.933, blue: 0.933, alpha: 1), range: range)
        return commentString
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textView!.frame = self.bounds
        if self.isWritingComment != nil {
            self.textView!.backgroundColor = UIColor(red:0.933, green:0.933, blue:0.933, alpha:1) /*#eeeeee*/
            self.button!.backgroundColor = UIColor(red:0.345, green:0.318, blue:0.424, alpha:1) /*#58516c*/
            let buttonX = CGRectGetWidth(self.bounds) - CGRectGetWidth(self.button!.frame) - 20
            self.button!.frame = CGRectMake(buttonX, 10, 80, 20)
        } else {
            self.textView!.backgroundColor = UIColor(red:0.898, green:0.898, blue:0.898, alpha:1) /*#e5e5e5*/
            self.button!.backgroundColor = UIColor(red:0.6, green:0.6, blue:0.6, alpha:1) /*#999999*/
            self.button!.frame = CGRectMake(10, 10, 80, 20)
        }
        var buttonSize = self.button!.frame.size
        buttonSize.height += 20
        buttonSize.width += 20
        let blockX = CGRectGetWidth(self.textView!.bounds) - buttonSize.width;
        let areaToBlockText = CGRectMake(blockX, 0, buttonSize.width, buttonSize.height)
        let buttonPath = UIBezierPath(rect: areaToBlockText)
        self.textView!.textContainer.exclusionPaths = [buttonPath]
    }
    
    func stopComposingComment() {
        self.textView!.resignFirstResponder()
    }
    
    // MARK: - Setters & Getters
    
    func setIsWritingComment(isWritingComment: Bool) {
        self.setIsWritingComment(isWritingComment)
    }
    
    func setIsWritingComment(isWritingComment: Bool, animated: Bool) {
        self.isWritingComment = isWritingComment
        if (animated) {
            UIView.animateWithDuration(0.2, animations: {
                self.layoutSubviews()
            })
        } else {
            self.layoutSubviews()
        }
    }
    
//    func setText(text: NSString) {
//        self.text = text as String
//        self.textView!.text = text as String
//        self.textView!.userInteractionEnabled = true
//        self.isWritingComment = text.length > 0
//    }
    
    // MARK: - Button Target
    
    func commentButtonPressed(sender: UIButton) {
        if self.isWritingComment != nil {
            self.textView!.resignFirstResponder()
            self.textView!.userInteractionEnabled = false
            self.delegate!.commentViewDidPressCommentButton!(self)
        } else {
            self.setIsWritingComment(true, animated: true)
            self.textView!.becomeFirstResponder()
        }
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        self.setIsWritingComment(true, animated: true)
        self.delegate!.commentViewWillStartEditing!(self)
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let statementAsNSString = textView.text as NSString
        let newText: NSString = statementAsNSString.stringByReplacingCharactersInRange(range, withString: text as String)
        self.delegate!.commentView!(self, textDidChange: newText)
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        let hasComment = !textView.text.isEmpty
        self.setIsWritingComment(hasComment, animated: true)
        return true
    }
}
