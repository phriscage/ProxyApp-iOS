//
//  MyURLProtocol.swift
//  ProxyApp
//
//  Created by Christopher Page on 4/9/16.
//  Copyright © 2016 Christopher Page. All rights reserved.
//

import UIKit
import CoreData

//var requestCount = 0
let markerRequestHandled = "request-already-handled"


class MyURLProtocol: NSURLProtocol, NSURLSessionDataDelegate {

  var connection: NSURLConnection!
  var mutableData: NSMutableData!
  var response: NSURLResponse!

  override class func canInitWithRequest(request: NSURLRequest) -> Bool {
    
    if let scheme = request.URL?.scheme where (scheme.rangeOfString("http") == nil) {
      return false
    }

    if NSURLProtocol.propertyForKey(markerRequestHandled, inRequest: request) != nil {
      return false
    }

    requestCount += 1
    print("Request #\(requestCount): URL = \(request.URL!.absoluteString)")

    return true
  }
  
  override class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
    return request
  }

  override class func requestIsCacheEquivalent(aRequest: NSURLRequest,
                                               toRequest bRequest: NSURLRequest) -> Bool {
    return super.requestIsCacheEquivalent(aRequest, toRequest:bRequest)
  }

//  override func startLoading() {
//    let url = self.request.URL!
//    // Create the new request
//    let newRequest = self.request.mutableCopy() as! NSMutableURLRequest
//    // Add the proxy header
//    newRequest.addValue(String(url), forHTTPHeaderField: proxyURLHeader)
////    // Add the Host header
////    newRequest.addValue(proxyURL, forHTTPHeaderField: "Host")
//    // Change the URL
////    newRequest.URL = (NSURL(string: proxyURL)) // production
//    newRequest.URL = (NSURL(string: "http://localhost:8000")) // development
//    // Set the property value
//    NSURLProtocol.setProperty(true, forKey: markerRequestHandled, inRequest: newRequest)
//    
////    NSLog("newRequest.URL: \(newRequest.URL)")
//    NSLog("newRequest.allHTTPHeaderFields: \(newRequest.allHTTPHeaderFields)")
//    
//    self.connection = NSURLConnection(request: newRequest, delegate: self)
//  }
  
  override func startLoading() {
    // Create the new request
    let newRequest = self.request.mutableCopy() as! NSMutableURLRequest
    // Set the property value
    NSURLProtocol.setProperty(true, forKey: markerRequestHandled, inRequest: newRequest)
    //    NSLog("newRequest.URL: \(newRequest.URL)")
    self.connection = NSURLConnection(request: newRequest, delegate: self)
  }
  
  override func stopLoading() {
    if self.connection != nil {
      self.connection.cancel()
    }
    self.connection = nil
  }
  
  // NSURLConnection delegate
  
  func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
    self.client!.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: .NotAllowed)
    self.response = response
    self.mutableData = NSMutableData()
  }
  
  // Handle redirects
  func connection(connection: NSURLConnection, willSendRequest request: NSURLRequest, redirectResponse response: NSURLResponse?) -> NSURLRequest?
  {
    if let response = response {
      client?.URLProtocol(self, wasRedirectedToRequest: request, redirectResponse: response)
    }
    return request
  }
  
  func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
    self.client!.URLProtocol(self, didLoadData: data)
    self.mutableData.appendData(data)
  }
  
  func connectionDidFinishLoading(connection: NSURLConnection!) {
    self.client!.URLProtocolDidFinishLoading(self)
  }
  
  func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
    self.client!.URLProtocol(self, didFailWithError: error)
    NSLog("* Error url: \(self.request.URL?.absoluteString)\n* Details: \(error)")
  }
  
}
