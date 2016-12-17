//
//  APIClient.swift
//  FlickrTest
//
//  Created by OkuderaYuki on 2016/12/17.
//  Copyright © 2016年 YukiOkudera. All rights reserved.
//

import UIKit
import Alamofire

class APIClient: NSObject {
    
    /// API Requests Result
    enum Result {
        case Success(Any)
        case Error(Error)
    }
    
    /// GET method
    func requestItems(urlString: String,
                      params: [String: Any] = [String: Any](),
                      headers: [String: Any] = [String: Any](),
                      completionHandler: @escaping (Result) -> () = {_ in})
    {
        let request = Alamofire.request(urlString, method: .get, parameters: params)
        
        request.response { response in
            if let error = response.error {
                completionHandler(.Error(error))
                return
            }
            if let data = response.data {
                completionHandler(.Success(data))
                return
            }
        }
    }
}
