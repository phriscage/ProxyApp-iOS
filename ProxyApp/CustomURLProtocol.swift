//
//  CustomURLProtocol.swift
//  ProxyApp
//
//  Created by Christopher Page on 4/21/16.
//  Copyright © 2016 Christopher Page. All rights reserved.
//

import Foundation
import UIKit

var requestCount = 0

class CustomURLProtocol:  NSURLProtocol, NSURLSessionDataDelegate, NSURLSessionTaskDelegate {
  
  private var dataTask:NSURLSessionDataTask?
  private var urlResponse:NSURLResponse?
  private var receivedData:NSMutableData?
  
  var test:Bool = false
  
  class var CustomKey:String {
    return "myCustomKey"
  }
  
  // MARK: NSURLProtocol
  
  override class func canInitWithRequest(request: NSURLRequest) -> Bool {
    
    if let scheme = request.URL?.scheme where (scheme.rangeOfString("http") == nil) {
      return false
    }
    
    if (NSURLProtocol.propertyForKey(CustomURLProtocol.CustomKey, inRequest: request) != nil) {
      return false
    }
    
    requestCount += 1
    print("Request #\(requestCount): URL = \(request.URL!.absoluteString)")
    
    return true
  }
  
  override class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
    return request
  }
  
  override func startLoading() {
    
    let newRequest = self.request.mutableCopy() as! NSMutableURLRequest
    
    // Set a custom header
    newRequest.addValue((self.request.URL?.absoluteString)!, forHTTPHeaderField: proxyURLHeader)

    // Set the CustomKey property to stop reloading NSURLProtocol
    NSURLProtocol.setProperty("true", forKey: CustomURLProtocol.CustomKey, inRequest: newRequest)
    
    var defaultConfigObj:NSURLSessionConfiguration;
    
    if isProxyMode == true {
      defaultConfigObj = Proxy.createSessionConfiguration("localhost:8080")

//    let defaultConfigObj = NSURLSessionConfiguration.defaultSessionConfiguration()
    } else {
      defaultConfigObj = NSURLSessionConfiguration.defaultSessionConfiguration()
    }
    
    let defaultSession = NSURLSession(configuration: defaultConfigObj, delegate: self, delegateQueue: nil)

    
    self.dataTask = defaultSession.dataTaskWithRequest(newRequest)
    self.dataTask!.resume()
    
  }
  
  override func stopLoading() {
    self.dataTask?.cancel()
    self.dataTask       = nil
    self.receivedData   = nil
    self.urlResponse    = nil
  }
  
  // MARK: NSURLSessionDataDelegate
  
  func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask,
                  didReceiveResponse response: NSURLResponse,
                                     completionHandler: (NSURLSessionResponseDisposition) -> Void) {
    
    self.client?.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: .NotAllowed)
    
    self.urlResponse = response
    self.receivedData = NSMutableData()
    
    completionHandler(.Allow)
  }
  
  func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
    self.client?.URLProtocol(self, didLoadData: data)
    
    self.receivedData?.appendData(data)
  }
  
  
  // MARK: NSURLSessionTask
  // Handle Redirects
  
  func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
    client?.URLProtocol(self, wasRedirectedToRequest: request, redirectResponse: response)

//    if let httpResponse = response as? NSHTTPURLResponse {
//      client?.URLProtocol(self, wasRedirectedToRequest: request, redirectResponse: httpResponse)
//    }
    completionHandler(nil)
  }
  
  // MARK: NSURLSessionTaskDelegate
  
  func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
    if error != nil && error!.code != NSURLErrorCancelled {
      self.client?.URLProtocol(self, didFailWithError: error!)
      NSLog("* Error url: \(self.request.URL?.absoluteString)\n* Details: \(error)")
    } else {
//      saveCachedResponse()
      self.client?.URLProtocolDidFinishLoading(self)
    }
  }
  
  // MARK: Private methods
  
  /**
   Do whatever with the data here
   */
  func saveCachedResponse () {
    let timeStamp = NSDate()
    let urlString = self.request.URL?.absoluteString
    let dataString = NSString(data: self.receivedData!, encoding: NSUTF8StringEncoding) as NSString?
    print("TimeStamp:\(timeStamp)\nURL: \(urlString)\n\nDATA:\(dataString)\n\n")
  }  
  
}

