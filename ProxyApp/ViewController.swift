//
//  ViewController.swift
//  ProxyApp
//
//  Created by Christopher Page on 4/6/16.
//  Copyright © 2016 Christopher Page. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, UIWebViewDelegate, UISearchBarDelegate {

  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var webView: UIWebView!
  @IBOutlet weak var backButton: UIBarButtonItem?
  @IBOutlet weak var forwardButton: UIBarButtonItem?
  
//  var isProxyMode:Bool = false
  var isProduction:Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.webView.delegate = self
    self.searchBar.delegate = self

    self.webView.keyboardDisplayRequiresUserAction = true
    self.webView.frame = self.view.frame
    
//    let url = NSURL(string: defaultURL)
//    let request = NSURLRequest(URL: url!)
//    self.webView.loadRequest(request)
    
    self.searchBar.autocapitalizationType = UITextAutocapitalizationType.None
    
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBarHidden = true
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.sendRequest(defaultURL)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @IBAction func onClickBackButton(sender: UIBarButtonItem) {
    self.webView?.goBack()
  }
  
  @IBAction func onClickForwardButton(sender: UIBarButtonItem) {
    self.webView?.goForward();
  }
  
  @IBAction func onClickRefreshButton(sender: UIBarButtonItem) {
    self.webView?.reload()
  }
  
    @IBAction func onClickProxyModeButton(sender: UIButton) {
      self.proxyModeButtonClicked(sender)
    }
  
  //  @IBAction func onClickTestButton(sender: UIBarButtonItem) {
  //    print("Test button clicked")
  //    self.barButtonClicked(sender)
  //  }
  
//  @IBAction func onClickEnvironmentMode(sender: UIButton) {
//    print("Environment button clicked")
//    self.environmentButtonClicked(sender)
//  }
//  
//  @IBAction func onClickAirplaneMode(sender: UIButton) {
//    print("airplane button clicked")
//    self.airplaneButtonClicked(sender)
//  }
  
  // MARK: - UIWebViewDelegate
  
  // Should Startloading view
  func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    
    //    NSLog("Initial request.allHTTPHeaderFields: \(request.allHTTPHeaderFields)")
    if request.URL!.absoluteString.rangeOfString("^http", options: .RegularExpressionSearch) == nil {
        //NSLog("Bad URL: \(request.URL)")
        return false
    }
    NSLog("shouldStartLoadWithRequest request: \(request)")

    return true
  }
  
  // Strart the view
  func webViewDidStartLoad(webView: UIWebView) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    self.refreshViews()
  }
  
  // Finish loading view
  func webViewDidFinishLoad(webView: UIWebView) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//    putStatus("Finish loading")
//    if let request = webView.request {
//      NSLog("webViewDidFinishLoad request: \(request)")
//      NSLog("webViewDidFinishLoad request.allHTTPHeaderFields: \(request.allHTTPHeaderFields)")
//      if let resp = NSURLCache.sharedURLCache().cachedResponseForRequest(request) {
//        if let response = resp.response as? NSHTTPURLResponse {
//          NSLog("response.statusCode: \(response.statusCode)")
//          NSLog("response.allHeaderFields: \(response.allHeaderFields)")
//        }
//      }
//    }
    
//    if let httpResponse = response as? NSHTTPURLResponse {
//      if let contentType = httpResponse.allHeaderFields["Content-Type"] as? String {
//        // use contentType here
//      }
//    }
    if let request = webView.request {
      NSLog("webViewDidFinishLoad request: \(request)")
      NSLog("webViewDidFinishLoad request.allHTTPHeaderFields: \(request.allHTTPHeaderFields)")
      self.searchBar?.text = webView.request?.URL?.absoluteString
      if let resp = NSURLCache.sharedURLCache().cachedResponseForRequest(request) {
        if let response = resp.response as? NSHTTPURLResponse {
          NSLog("response.statusCode: \(response.statusCode)")
          NSLog("response.allHeaderFields: \(response.allHeaderFields)")
//          // Handle permenant 301 redirects
//          if response.statusCode == 301 {
//            if let locationHeader = response.allHeaderFields["Location"] as? String {
//              if let URL = NSURL(string: locationHeader) {
//                self.webView?.loadRequest(NSURLRequest(URL: URL))
//              }
//            }
//          }
        } else {
          NSLog("response failed: \(request)")
        }
      }
    }
    self.refreshViews()
  }
  
  // failed to load
  func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
    if error!.code != NSURLErrorCancelled {
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      
      let alert = UIAlertView(title: "Error", message: error!.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
      alert.show()
    }
  }
  
  // update the forward/back buttons
  func refreshViews() {
    backButton?.enabled = webView?.canGoBack ?? false
    forwardButton?.enabled = webView?.canGoForward ?? false
  }

  
  // MARK: - UISearchBarDelegate
  
  // UISearchBar did change
//  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//    searchBar.text = searchText.lowercaseString
//  }

  // searchBarShouldEndEditing
  func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
    self.sendRequest(searchBar.text!)
    return true
  }
  
  // searchBarSearchButtonClicked
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    self.sendRequest(searchBar.text!)
  }
  
  
  // MARK: - Utilities that should be moved somewhere else
  
  // sendRequest from seaarchBar
  func sendRequest(URLOrKeyword: String) -> Bool {
    // Check for emtpty
    if !URLOrKeyword.isEmpty {
      var URLOrKeyword = URLOrKeyword
      var URLString: String
      // prepend HTTP protocol http://
      if URLOrKeyword.rangeOfString("^https?://", options: .RegularExpressionSearch) == nil {
         URLOrKeyword = String(format:"http://%@", URLOrKeyword)
      }
      // Check if valid URL syntax
      if verifyUrl(URLOrKeyword) {
        URLString = URLOrKeyword
      } else {
        // Append to the googleSearchURL
        URLString = String(format: googleSearchURL, String(URLOrKeyword).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())!)
      }
      print("URL: '\(URLString)', URLOrKeyword: \(URLOrKeyword)'")
      if let URL = NSURL(string: URLString) {
        self.webView?.loadRequest(NSURLRequest(URL: URL))
        self.searchBar?.text = URL.absoluteString
        return true
      } else {
        print("Something broke.")
      }
    }
    return false
  }
  
  // verify if a URL is valid
  func verifyUrl(urlString: String?) -> Bool {
    //Check for nil
    if let urlString = urlString {
      // create NSURL instance
      if let url = NSURL(string: urlString) {
        // check if your application can open the NSURL instance
        return UIApplication.sharedApplication().canOpenURL(url)
      }
    }
    return false
  }
  
  // Base64 encoding HTTP header
  //
  //      print("setting random base64 encoded header")
  
  //      let client_id = "9062702a-d9a8-4e09-be84-c08aa96ff506"
  //      let client_secret = "48309e6d-fae7-4f44-b1e3-6b548f5cc40d"
  //      let loginString = NSString(format: "%@:%@", client_id, client_secret)
  //      let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
  //      let base64LoginString = loginData.base64EncodedStringWithOptions([])

  // proxyMode UIButton Selected
  func proxyModeButtonClicked(sender:UIButton)
  {
    dispatch_async(dispatch_get_main_queue(), {
      
      sender.selected = !sender.selected;
      
      if sender.selected == true {
        sender.tintColor = UIColor.clearColor()
        sender.setTitle("On", forState: UIControlState.Selected)
        sender.setTitleColor(UIColor.greenColor(), forState: UIControlState.Selected)
        isProxyMode = true
        print("proxyMode on")
      } else {
        isProxyMode = false
        sender.setTitle("Off", forState: UIControlState.Normal)
        print("proxyMode off")
      }
      
    });
  }
  
  
//  // Airplance UIButton Selected
//  func airplaneButtonClicked(sender:UIButton)
//  {
//    dispatch_async(dispatch_get_main_queue(), {
//      
//      //      sender.selected = !sender.selected;
//      //
//      //      if sender.selected == true {
//      //        sender.tintColor = UIColor.clearColor()
//      //        sender.setTitleColor(UIColor.greenColor(), forState: UIControlState.Selected)
//      //        print("selected")
//      //      }
//      
//      sender.selected = !sender.selected;
//      
//      if sender.selected == true {
//        sender.tintColor = UIColor.clearColor()
//        sender.setTitleColor(UIColor.greenColor(), forState: UIControlState.Selected)
//        isProxyMode = true
////        self.proxyMode = true
//        print("proxyMode on")
//      } else {
////        self.proxyMode = false
//        isProxyMode = false
//        print("proxyMode off")
//      }
//      
//    });
//  }
  
//   Development/Production UIButton Selected
//  func environmentButtonClicked(sender:UIButton)
//  {
//    dispatch_async(dispatch_get_main_queue(), {
//      
//      sender.selected = !sender.selected;
//      
//      if sender.selected == true {
//        sender.tintColor = UIColor.clearColor()
//        sender.setTitle("Prod", forState: UIControlState.Selected)
//        sender.setTitleColor(UIColor.greenColor(), forState: UIControlState.Selected)
//        self.isProduction = true
//        print("isProduction on")
//      } else {
//        self.isProduction = false
//        sender.setTitle("Dev", forState: UIControlState.Normal)
//        print("isProduction off")
//      }
//      
//    });
//  }
  
  //  // Test UIBarButtoItem Selected
  //  func barButtonClicked(sender:UIBarButtonItem)
  //  {
  //    dispatch_async(dispatch_get_main_queue(), {
  //
  //      if self.isPressed == false {
  //        sender.tintColor = UIColor.greenColor()
  //        self.isPressed = true
  //      } else {
  //        sender.tintColor = UIColor(colorLiteralRed: 14.0/255, green: 122.0/255, blue: 254.0/255, alpha: 1.0)
  //        self.isPressed = false
  //      }
  //
  //    });
  //  }

  
}

