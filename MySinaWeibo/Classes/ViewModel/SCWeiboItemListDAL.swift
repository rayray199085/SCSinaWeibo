//
//  SCWeiboItemListDAL.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 9/4/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import Foundation

/// data access layer
class SCWeiboItemListDAL{
    
    /// 1.viewModel -> DAL
    /// 2. check local database if have data return
    /// 3. otherwise link to the internet to get data
    /// 4. update local database
    /// 5. return data
    /// - Parameters:
    ///   - since_id: since id
    ///   - max_id: max id
    ///   - completion: return data array and success mark
    class func loadWeiboItems(since_id : Int64 = 0, max_id : Int64 = 0, completion:@escaping (_ list:[[String:Any]]?,_ isSuccess : Bool)->()){
        // check local data from database if exists return
        guard let userId = SCNetWorkManager.sharedManager.userAccount.uid else{
            return
        }
        let array = SCSQLiteManager.sharedManager.loadWeibo(userId: userId, since_id: since_id, max_id: max_id)
        if array.count > 0{
            completion(array,true)
            return
        }
        // connect to the server and get data
        SCNetWorkManager.sharedManager.responseResult { (json, isSuccess) in
            if !isSuccess{
                completion(nil,isSuccess)
                return
            }
            // update database
            guard let json = json else{
                completion(nil,isSuccess)
                return
            }
            SCSQLiteManager.sharedManager.updateWeibo(userId: userId, array: json)
            completion(json,isSuccess)
        }
    }
}
