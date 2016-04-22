//
//  CustomURLProtocol.swift
//  ProxyApp
//
//  Created by Christopher Page on 4/21/16.
//  Copyright © 2016 Christopher Page. All rights reserved.
//

import Foundation
import UIKit

class CustomURLProtocol:  NSURLProtocol, NSURLSessionDataDelegate, NSURLSessionTaskDelegate {
  
  private var dataTask:NSURLSessionDataTask?
  private var urlResponse:NSURLResponse?
  private var receivedData:NSMutableData?
  
  class var CustomKey:String {
    return "myCustomKey"
  }
  
  // MARK: NSURLProtocol
  
  override class func canInitWithRequest(request: NSURLRequest) -> Bool {
    if (NSURLProtocol.propertyForKey(CustomURLProtocol.CustomKey, inRequest: request) != nil) {
      return false
    }
    
    return true
  }
  
  override class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
    return request
  }
  
  override func startLoading() {
    
    let newRequest = self.request.mutableCopy() as! NSMutableURLRequest
    
    NSURLProtocol.setProperty("true", forKey: CustomURLProtocol.CustomKey, inRequest: newRequest)
    
    let defaultConfigObj = NSURLSessionConfiguration.defaultSessionConfiguration()
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
  
  // MARK: NSURLSessionTaskDelegate
  
  func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
    if error != nil && error!.code != NSURLErrorCancelled {
      self.client?.URLProtocol(self, didFailWithError: error!)
    } else {
      saveCachedResponse()
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

