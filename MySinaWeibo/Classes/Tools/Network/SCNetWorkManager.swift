//
//  SCNetWorkManager.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 23/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
// 

import UIKit
import Alamofire
class SCNetWorkManager{
    /// a singleton pattern of SCNetWorkManager
    static let sharedManager = SCNetWorkManager()
    lazy var userAccount = SCUserAccount()
    var userlogon : Bool{
        return userAccount.access_token != nil
    }
    /// Handle token issues and call sendRequest method
    ///
    /// - Parameters:
    ///   - urlString: url string
    ///   - params: parameters in a dictionary [String:Any]?
    ///   - method: get/post
    ///   - data: binary data (for uploading file method: post)
    ///   - name: field for uploading file to server (for uploading file method: post)
    ///   - completion: Any?
    func requestToken(urlString:String, params:[String:Any]?,method:HTTPMethod,name:String? = nil,data:Data? = nil, completion :@escaping (_ json:Any?,_ isSuccess:Bool)->()){
        guard let token = userAccount.access_token else {
            NotificationCenter.default.post(name: NSNotification.Name(SCUserShouldLoginNotification), object: nil)
            completion(nil,false)
             return
        }
        var params = params
        if params == nil{
            params = [String :Any]()
        }
        // params should not be nil at here
        params!["access_token"] = token
        if let name = name,
            let data = data,
            let params = params{
            upload(urlString: urlString, data: data, name: name, params: params, completion: completion)
        }else{
            sendRequest(urlString: urlString, params: params, method: method, completion: completion)
        }
    }
    ///
    /// - Parameters:
    ///   - urlString: url string
    ///   - params: parameters in a dictionary [String:Any]?
    ///   - method: get/post
    ///   - completion: reponse data
    func sendRequest(urlString:String, params:[String:Any]?,method:HTTPMethod,completion :@escaping (_ json:Any?,_ isSuccess:Bool)->()){
        guard let url = URL(string: urlString) else {
            return
        }
        Alamofire.request(url, method: method, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            // Invalid Access might happen if token is not valid
            if response.result.isSuccess{
                let json = response.result.value
                let res = json as? [String : Any]
                if let error = res?["error"] as? String{
                    if error == "invalid_access_token"{
                        //invalid access token
                        NotificationCenter.default.post(name: NSNotification.Name(SCUserShouldLoginNotification), object: "Invalid Token")
                    }
                    completion(nil,false)
                    return
                }
                completion(json,true)
            }else{
                if let error = response.result.error{
                    print(error)
                }
                completion(nil,false)
            }
        }
    }
    
    /// upload file
    /// method should be post
    /// - Parameters:
    ///   - urlString: url string
     ///   - data: binary data
    ///   - name: field for uploading file to server
    ///   - params: dictionary for parameters
    ///   - completion: response in json
    func upload(urlString: String,data: Data,name : String, params:[String: Any], completion :@escaping (_ json:Any?,_ isSuccess:Bool)->()){
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(data, withName: name, fileName: "scimage.png", mimeType: "application/octet-stream")
                
                for (key, value) in params{
                    multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
                }
        },
            to: urlString,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        let json = response.result.value
                        let res = json as? [String : Any]
                        if let error = res?["error"] as? String{
                            if error == "invalid_access_token"{
                                //invalid access token
                                NotificationCenter.default.post(name: NSNotification.Name(SCUserShouldLoginNotification), object: "Invalid Token")
                            }
                            completion(nil,false)
                            return
                        }
                        completion(json,true)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                    completion(nil,false)
                }
        }
        )
    }
}
