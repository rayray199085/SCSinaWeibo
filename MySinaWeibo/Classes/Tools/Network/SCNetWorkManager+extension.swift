//
//  SCNetWorkManager+extension.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 24/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import Foundation
import Alamofire

extension SCNetWorkManager{
    /// array is nil if invalid access, otherwise return data
    ///
    /// - Parameters:
    ///   - since_id: load latest weibo items since id default 0
    ///   - max_id: load more weibo items id less than max id default 0
    ///   - completion: weibo items list or nil if fail [[String:Any]]?
    func responseResult(since_id : Int64 = 0, max_id : Int64 = 0,
        completion:@escaping (_ list:[[String:Any]]?,_ isSuccess : Bool)->()){
        let urlString = "https://api.weibo.com/2/statuses/home_timeline.json"
        let params = ["since_id" : "\(since_id)","max_id" : "\(max_id > 0 ? max_id - 1 : 0)"]
        requestToken(urlString: urlString, params: params, method: HTTPMethod.get) {
            (json, isSuccess) in
            let res = json as? [String: Any]
            let array = res?["statuses"] as? [[String:Any]]
            completion(array,isSuccess)
        }
    }
    
    /// get the number of unread weibo items
    func unreadCount(completion:@escaping (_ count:Int)->()){
        guard let uid = userAccount.uid else {
            return
        }
        let urlString = "https://rm.api.weibo.com/2/remind/unread_count.json"
        let params = ["uid":uid]
        requestToken(urlString: urlString, params: params, method: HTTPMethod.get) { (json, isSuccess) in
            let res = json as? [String:Any]
            let statusCount = res?["status"] as? Int
            completion(statusCount ?? 0)
        }
    }
}

// MARK: - OAuth2.0
extension SCNetWorkManager{
    
    /// Acquire access token
    /// - Parameters:
    ///   - code: code for getting access_token
    ///   - completion: success or failure
    func getAccessToken(code: String, completion: @escaping (_ isSuccess: Bool)->()){
        let urlString = "https://api.weibo.com/oauth2/access_token"
        let params = ["client_id":SCAppKey,
                      "client_secret":SCAppSecret,
                      "grant_type":"authorization_code",
                      "code":code,
                      "redirect_uri":SCRedirectURI]
        sendRequest(urlString: urlString, params: params, method: HTTPMethod.post) { (json, isSuccess) in
            let res = json as? [String:Any]
            self.userAccount.yy_modelSet(with: res ?? [:])
            // load user info
            self.loadUserInfo(completion: { (dict) in
                self.userAccount.yy_modelSet(with: dict)
                // save model info
                self.userAccount.saveAccountInfo()
                completion(isSuccess)
            })
        }
    }
}

// MARK: - get user info
extension SCNetWorkManager{
    func loadUserInfo(completion:@escaping (_ dict:[String :Any])->()){
        guard let uid = userAccount.uid else {
            return
        }
        let urlString = "https://api.weibo.com/2/users/show.json"
        let params = ["uid":uid]
        requestToken(urlString: urlString, params: params, method: HTTPMethod.get) { (json, isSuccess) in
            let res = json as? [String:Any]
            completion(res ?? [:])
        }
    }
}


// MARK: - post a weibo
extension SCNetWorkManager{
    
    /// post a new weibo
    ///
    /// - Parameters:
    ///   - textContent: text content
    ///   - image: upload a image (optional)
    ///   - completion: response
    func postWeibo(textContent: String,image: UIImage? ,completion:@escaping (_ dict:[String:Any],_ isSuccess:Bool)->())->(){
        let urlString = "https://api.weibo.com/2/statuses/share.json"
        let params = ["status": "\(textContent) \(SCSecurityDomain)"]
        var name: String?
        var data: Data?
        if image != nil{
            name = "pic"
            data = UIImage.pngData(image!)()
        }
        requestToken(urlString: urlString, params: params, method: HTTPMethod.post, name: name, data: data) { (json, isSuccess) in
            let res = json as? [String:Any]
            completion(res ?? [:],isSuccess)
        }
    }
    
    func repostWeibo(weiboID: Int64, textContent: String, completion:@escaping (_ dict :[String : Any])->()) {
        let urlString = "https://api.weibo.com/2/statuses/share.json"
        let params = ["id":"\(weiboID)","status": "\(textContent) \(SCSecurityDomain)"]
        requestToken(urlString: urlString, params: params, method: HTTPMethod.post) { (json, isSuccess) in
            let res = json as? [String:Any]
            completion(res ?? [:])
        }
    }
}
