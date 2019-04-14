//
//  SCWeiboItemListViewModel.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 24/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import Foundation
import SDWebImage

/// the max number of pulling up
private let pullUpMaximumCount = 3
class SCWeiboItemListViewModel {
    lazy var weiboItemList = [SCWeiboItemViewModel]()
    var imageLength = 0
    let group = DispatchGroup()
    // accumulate the number of errors during pulling up
    private var pullUpErrorTimes = 0
    /// load weibo item model by using yy model
    ///
    /// - Parameters:
    ///   - pullUp: check whether should append more weibo items
    ///   - completion: a bool value, success: true
    func loadWeiboItem(pullUp:Bool, completion:@escaping (_ isSuccess:Bool, _ shouldRefreshTable :Bool)->()) {
        if pullUp && pullUpErrorTimes > pullUpMaximumCount{
            completion(true, false)
            return
        }
        // default value is 0,
        let since_id = pullUp ? 0 : (weiboItemList.first?.weiboItem.id ?? 0)
        let max_id = !pullUp ? 0 : (weiboItemList.last?.weiboItem.id ?? 0)
        SCNetWorkManager.sharedManager.responseResult(since_id: since_id, max_id: max_id) { (array, isSuccess) in
            if !isSuccess{
                completion(isSuccess,false)
                return
            }
            var modelArray = [SCWeiboItemViewModel]()
            
            for dict in array ?? []{
                let weiboItem = SCWeiboItem()
                //In model, the format of attributes should be @objc var xxx
                weiboItem.yy_modelSet(with: dict)
                modelArray.append(SCWeiboItemViewModel.init(weiboItem: weiboItem))
            }
            if pullUp{
                self.weiboItemList += modelArray
            }else{
                // latest items should appear at the beginning
                self.weiboItemList = modelArray + self.weiboItemList
            }
            if pullUp && modelArray.count == 0{
                self.pullUpErrorTimes += 1
                completion(isSuccess, false)
            }else{
                self.cacheSingleImage(list: modelArray,completion: completion)
            }
        }
//        user database to cache data
//        SCWeiboItemListDAL.loadWeiboItems(since_id: since_id, max_id: max_id) { (array, isSuccess) in
//            if !isSuccess{
//                completion(isSuccess,false)
//                return
//            }
//            var modelArray = [SCWeiboItemViewModel]()
//
//            for dict in array ?? []{
//                let weiboItem = SCWeiboItem()
//                //In model, the format of attributes should be @objc var xxx
//                weiboItem.yy_modelSet(with: dict)
//                modelArray.append(SCWeiboItemViewModel.init(weiboItem: weiboItem))
//            }
//            if pullUp{
//                self.weiboItemList += modelArray
//            }else{
//                // latest items should appear at the beginning
//                self.weiboItemList = modelArray + self.weiboItemList
//            }
//            if pullUp && modelArray.count == 0{
//                self.pullUpErrorTimes += 1
//                completion(isSuccess, false)
//            }else{
//                self.cacheSingleImage(list: modelArray,completion: completion)
//            }
//        }
    }
    
    /// cache single image
    /// for preset imageView size
    /// - Parameter list: [SCWeiboItemViewModel]
    private func cacheSingleImage(list: [SCWeiboItemViewModel],completion:@escaping (_ isSuccess:Bool, _ shouldRefreshTable :Bool)->()){
        for weiboViewModel in list{
            if weiboViewModel.picURLs?.count != 1{
                continue
            }
            guard let pic =  weiboViewModel.picURLs?[0].thumbnail_pic,
                let url = URL(string: pic) else{
                continue
            }
            group.enter()
            SDWebImageManager.shared().imageDownloader?.downloadImage(with: url, options: [], progress: nil, completed: { (image, _, _, _) in
                if let image = image,
                    let data = image.pngData(){
                    self.imageLength += data.count
                    weiboViewModel.updateSingleImageSize(image: image)
                    self.group.leave()
                }
            })
        }
        group.notify(queue: DispatchQueue.main) {
            completion(true,true)
        }
    }
}
