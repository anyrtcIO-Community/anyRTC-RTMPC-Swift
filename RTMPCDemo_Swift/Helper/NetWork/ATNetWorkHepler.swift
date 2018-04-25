//
//  ATNetWorkHepler.swift
//  RTMPCDemo_Swift
//
//  Created by jh on 2018/3/8.
//  Copyright © 2018年 jh. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ATNetWorkHepler: NSObject {
    
    class func getResponseData(_ url:String, parameters:[String:AnyObject]? = nil, success:@escaping(_ result:JSON)-> Void, error:@escaping (_ error:NSError)->Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        Alamofire.request(url,method: HTTPMethod.post, parameters: parameters).responseJSON { (response) in
            if let jsonData = response.result.value {
                success(JSON(jsonData))
            } else if let er = response.result.error {
                error(er as NSError)
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }
    }
}
