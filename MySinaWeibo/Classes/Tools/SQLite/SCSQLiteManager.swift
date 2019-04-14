//
//  SCSQLiteManager.swift
//  LearnFMDB
//
//  Created by Stephen Cao on 9/4/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import Foundation
import FMDB
private let maxDBDataCacheTime:TimeInterval = -3 * 24 * 60 * 60
class SCSQLiteManager{
    static let sharedManager = SCSQLiteManager()
    let queue: FMDatabaseQueue
    private init() {
        let dbName = "status.db"
        let path = NSString.getDocumentDirectory().appendingPathComponent(dbName)
        print(path)
        queue = FMDatabaseQueue(path: path)!
        createTable()
        NotificationCenter.default.addObserver(self, selector: #selector(clearDBCache), name: UIApplication.willResignActiveNotification, object: nil)
    }
 
    /// clear database cache
    @objc private func clearDBCache(){
        let expiredDateString = Date.getExpiredRecordsDateString(expiryLength: maxDBDataCacheTime)
        let sql = "DELETE FROM T_Status WHERE createTime < ?"
        queue.inTransaction { (db, rollback) in
            if db.executeUpdate(sql, withArgumentsIn: [expiredDateString]) == true{
                print("\(db.changes) records has been deleted")
            }else{
                print(db.lastError())
                rollback.pointee = true
            }
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }
}

// MARK: - create table and other private functions
private extension SCSQLiteManager{
    
    /// create table
    func createTable() {
        // prepare sql
        guard let path = Bundle.main.path(forResource: "status.sql", ofType: nil),
        let sql = try? String(contentsOfFile: path) else {
            return
        }
        // execute sql
        queue.inDatabase { (db) in
            if db.executeStatements(sql) == true{
                print("success")
            }else{
                print(db.lastError())
            }
        }
    }
    /// execute sql and return a dictionary array
    ///
    /// - Parameter sql: query record set
    /// - Returns: dictionary array
    func queryRecordSet(sql:String)->[[String:Any]]{
        var result = [[String:Any]]()
        queue.inDatabase { (db) in
            guard  let resultSet = db.executeQuery(sql, withArgumentsIn: []) else{
                return
            }
            while resultSet.next(){
                let columnCount = resultSet.columnCount
                var dict = [String:Any]()
                for index in 0..<columnCount{
                    guard  let columnName = resultSet.columnName(for: index),
                        let value = resultSet.object(forColumnIndex: index) else{
                            continue
                    }
                    dict[columnName] = value
                }
                result.append(dict)
            }
        }
         return result
    }
}

// MARK: - basic operations
extension SCSQLiteManager{
    
    /// insert or update weibo item
    /// - Parameters:
    ///   - userId: current user id
    ///   - array: weibo items list
    func updateWeibo(userId: String, array: [[String: Any]]){
        
        /// statusId: weibo id
        /// userId: current user id
        /// status: json in binary data
        let sql = "INSERT OR REPLACE INTO T_Status (statusId,userId,status) VALUES(?,?,?);"
        queue.inTransaction { (db, rollback) in
            // iteratively insert weibo iten into db
            for dict in array{
                guard let statusId = dict["idstr"] as? String,
                    let data = try? JSONSerialization.data(withJSONObject: dict, options: []) else{
                        continue
                }
                if db.executeUpdate(sql, withArgumentsIn: [statusId,userId,data]) == false{
                    rollback.pointee = true
                    break
                }
            }
        }
    }
    
    /// load weibo items
    /// - Parameters:
    ///   - userId: user id
    ///   - since_id: for pulling down to load weibo item whose id is larger than since id
    ///   - max_id: for pulling up to load more weibo item whose id is smaller than max id
    /// - Returns: dictionary array
    func loadWeibo(userId: String, since_id : Int64 = 0, max_id : Int64 = 0)->[[String: Any]]{
        var sql = "SELECT statusId,userId,status FROM T_Status \n"
        sql += "WHERE userId=\(userId) \n"
        if since_id > 0{
            sql += "AND statusId > \(since_id) \n"
        }else if max_id > 0{
           sql += "AND statusId < \(max_id) \n"
        }
        sql += "ORDER BY statusId DESC \n"
        sql += "LIMIT 20;"
        let array = queryRecordSet(sql: sql)
        var result = [[String : Any]]()
        for dict in array{
            guard let data = dict["status"] as? Data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else{
                continue
            }
            result.append(json)
        }
        return result
    }
}
