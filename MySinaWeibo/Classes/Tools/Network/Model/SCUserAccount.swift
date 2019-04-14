//
//  SCUserAccount.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 26/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit
private let fileName = "useraccountinfo.json"
/// User Account Basic Information Model
class SCUserAccount: NSObject {
    @objc var access_token : String?
    @objc var uid : String?
    @objc var expires_in : TimeInterval = 0{
        didSet{
           expiresDate = Date(timeIntervalSinceNow: expires_in)
        }
    }
    @objc var expiresDate : Date?
    // user info
    @objc var screen_name : String?
    @objc var avatar_large : String?
    @objc var location : String?
    override var description: String{
        return yy_modelDescription()
    }
    
    override init() {
        super.init()
        let path = NSString.getDocumentDirectory().appendingPathComponent(fileName)
        guard let data = try? NSData.init(contentsOfFile: path) as Data,
              let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
            return
        }
        yy_modelSet(with: dict)
        if expiresDate?.compare(Date()) != ComparisonResult.orderedDescending{
            // token is out of date
            access_token = nil
            uid = nil
            // remove json file
            try? FileManager.default.removeItem(atPath: path)
        }
    }
    
    /// Save user information in JSON for next time login automatically
    func saveAccountInfo(){
        var dict = (yy_modelToJSONObject() as? [String :Any]) ?? [:]
        dict.removeValue(forKey: "expires_in")
        let path = NSString.getDocumentDirectory().appendingPathComponent(fileName)
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []) else{
            return
        }
        (data as NSData).write(toFile: path, atomically: true)
    }
}
