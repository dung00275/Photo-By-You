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

enum APIType:URLRequestConvertible {
    case Login
    var URLRequest: NSMutableURLRequest{
        switch self {
        case .Login:
            let URLApi = NSURL(string: APIInstagram)
            let URLLogin = NSURLRequest(URL:NSURL(string: "oauth/authorize/", relativeToURL: URLApi)!)
            
            let param = ["client_id":kClientId,
                         "redirect_uri":"PhotoByYou://authorize",
                         "response_type":"code"]
            let encoding = ParameterEncoding.URL.encode(URLLogin, parameters: param)
            
            return encoding.0
            
        }
    }
}