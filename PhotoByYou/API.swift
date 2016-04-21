//
//  API.swift
//  PhotoByYou
//
//  Created by Dung Vu on 4/21/16.
//  Copyright © 2016 Dung Vu. All rights reserved.
//

import Foundation
import Alamofire

let kClientId = "2716205da1714428b7ce706a29469fe7"
let kClientSerectId = "f2e776aea59845e19bc3d571edb4aea4"
let APIInstagram = "https://api.instagram.com"
let kRedirectURI = "PhotoByYou://authorize"
enum APIType:URLRequestConvertible {
    case Login,
    RequestAccessToken
    
    var URLRequest: NSMutableURLRequest{
        var request:NSURLRequest!
        var params:[String:AnyObject]?
        let URLApi = NSURL(string: APIInstagram)
        switch self {
        case .Login:
            request = NSURLRequest(URL:NSURL(string: "oauth/authorize/", relativeToURL: URLApi)!)
            params = ["client_id":kClientId,
                         "redirect_uri":kRedirectURI,
                         "response_type":"code"]
        case .RequestAccessToken:
            request = NSURLRequest(URL:NSURL(string: "/oauth/access_token", relativeToURL: URLApi)!)
        }
        
        let encoding = ParameterEncoding.URL.encode(request, parameters: params)
        return encoding.0
    }
}