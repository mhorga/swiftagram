//
//  LoginViewController.swift
//  Swiftagram
//
//  Created by Marius Horga on 3/14/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UIWebViewDelegate {

    let LoginViewControllerDidGetAccessTokenNotification = "LoginViewControllerDidGetAccessTokenNotification"
    var webView: UIWebView?
    
    func redirectURI() -> NSString {
        return "http://localhost"
    }
    
    override func loadView() {
        var webView = UIWebView()
        webView.delegate = self
        self.title = "Login"
        self.webView = webView
        self.view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let urlString = "https://instagram.com/oauth/authorize/?client_id=\(DataSource.instagramClientID)&redirect_uri=\(redirectURI)&response_type=token"
        let url = NSURL(string: urlString)
        if url != nil {
            let request = NSMutableURLRequest(URL: url!)
            webView!.loadRequest(request)
        }
    }
    
    deinit {    //override func dealloc() {
        clearInstagramCookies()
        //webView!.delegate = nil
    }
    
    // This prevents caching the credentials in the cookie jar.
    func clearInstagramCookies() {
        var cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies as [NSHTTPCookie]
        for cookie in cookies {
            let domainRange = cookie.domain.rangeOfString("instagram.com") as Range<String.Index>?
            //if domainRange.location != NSNotFound {
                NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
            //}
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let urlString = NSString(string: request.URL.absoluteString!)
        if urlString.hasPrefix(redirectURI()) {
            // This contains our auth token
            let rangeOfAccessTokenParameter = urlString.rangeOfString("access_token=")
            let indexOfTokenStarting = rangeOfAccessTokenParameter.location + rangeOfAccessTokenParameter.length
            let accessToken = urlString.substringFromIndex(indexOfTokenStarting)
            NSNotificationCenter.defaultCenter().postNotificationName(LoginViewControllerDidGetAccessTokenNotification, object: accessToken)
            return false
        }
        if (navigationType == UIWebViewNavigationType.LinkClicked){
            let backButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: "Back")
            navigationItem.leftBarButtonItem = backButton
        }
        return true
    }
    
    func Back() {
        webView?.goBack()
    }
}
