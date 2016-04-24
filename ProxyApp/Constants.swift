//
//  AppDelegate.swift
//  WebProxy
//
//  Created by Christopher Page on 3/11/16.
//  Copyright © 2016 Christopher Page. All rights reserved.
//

import Foundation


let defaultURL = "http://example.com"

let googleSearchURL = "http://google.com/search?q=%@"
let googleHTTPSURL = "https://google.com"
let googleHTTPURL = "http://google.com"

//let sqlitePath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as String

// Proxy settings
let proxyFQDN = "web-proxy-1219.appspot.com"
let proxyURL = "https://\(proxyFQDN)"
let org = "Pageone"
let proxyURLHeader = "\(org).Proxy.Url"
var isProxyMode:Bool = false
var username: String!
var password: String!