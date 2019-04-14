//
//  SCWeiboItemViewModel.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 28/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import Foundation

/// Sing weibo item model
class SCWeiboItemViewModel: CustomStringConvertible{
    var weiboItem : SCWeiboItem
    var vipIcon: UIImage?
    var vipCertificationIcon: UIImage?
    var weiboItemAttrText: NSAttributedString?
    var repostDetailsAttrText : NSAttributedString?
    var repostString: String?
    var commentString: String?
    var likeString: String?
    var picturesViewSize = CGSize()
    var picURLs : [SCPictureItem]?{
        return weiboItem.retweeted_status?.pic_urls ?? weiboItem.pic_urls
    }
    var sourceName: String?
    // calculate row height for setting cell height
    var rowHeight :CGFloat = 0
    
    /// init method
    ///
    /// - Parameter weiboItem: weibo model
    init(weiboItem:SCWeiboItem) {
        self.weiboItem = weiboItem
        let vipRank = weiboItem.user?.mbrank ?? 0
        if vipRank > 0 && vipRank <= 7{
            vipIcon = UIImage(named: "common_icon_membership_level\(vipRank)")
        }
        switch weiboItem.user?.verified_type {
        case 0:
            vipCertificationIcon = UIImage(named: "avatar_vip")
        case 2, 3, 5:
            vipCertificationIcon = UIImage(named: "avatar_enterprise_vip")
        case 220:
            vipCertificationIcon = UIImage(named: "avatar_grassroot")
        default:
            break
        }
        repostString = getCountString(count: weiboItem.reposts_count, defaultStr: "repost")
        commentString = getCountString(count: weiboItem.comments_count, defaultStr: "comment")
        likeString = getCountString(count: weiboItem.attitudes_count, defaultStr: "like")
        picturesViewSize = setPicturesViewSize(count: picURLs?.count ?? 0)
        
        let repostUsername = weiboItem.retweeted_status?.user?.screen_name ?? ""
        let repostDetails = weiboItem.retweeted_status?.text ?? ""
        let repostDetailsText = "@\(repostUsername):\(repostDetails)"
        repostDetailsAttrText = SCEmoticonsManager.sharedManager.getAttributedString(string: repostDetailsText, font: UIFont.systemFont(ofSize: 14))
        if let weiboItemDetailsText = weiboItem.text{
             weiboItemAttrText = SCEmoticonsManager.sharedManager.getAttributedString(string: weiboItemDetailsText, font: UIFont.systemFont(ofSize: 15))
        }
        sourceName = "From: " + (weiboItem.source?.getURLAndSourceByRegex()?.sourceName ?? "")
        updateRowHeight()
    }
    var description: String{
        return weiboItem.description
    }
    
    /// get repost, comment and like count in string
    ///
    /// - Parameters:
    ///   - count: repost/comment/like count
    ///   - defaultStr: default string
    /// - Returns: count in string
    private func getCountString(count:Int, defaultStr: String)->String{
        if count == 0{
            return defaultStr
        }
        else if count > 1000{
            let bigCount = NSString.init(format: "%.1lfk", CGFloat(count)/1000) as String
            return bigCount
        }else{
            return "\(count)"
        }
    }
    /// calculate picturesView height according to picture count
    ///
    /// - Parameter count: picture count
    /// - Returns: picturesView size
    private func setPicturesViewSize(count: Int)->CGSize{
        if count == 0 {
            return CGSize()
        }
        let row = (count - 1) / 3 + 1
        var height = SCPicturesViewOutterMargin
        height += CGFloat(row) * SCPictureViewImageWidth
        height += CGFloat(row - 1) * SCPicturesViewInnerMargin
        return CGSize(width: SCPicturesViewWidth, height: height)
    }
    
    /// update picture view size when has one image
    ///
    /// - Parameter image: cache image
    func updateSingleImageSize(image:UIImage){
        var size = image.size
        let maxWidth: CGFloat = 200
        let minWidth: CGFloat = 40
        if size.width > maxWidth {
            size.width = maxWidth
            size.height = size.width * image.size.height / image.size.width
        }
        if size.width < minWidth {
            size.width = minWidth
            size.height = size.width * image.size.height / image.size.width / 4
        }
        if size.height > 200 {
            size.height = 200
        }
        size.height += SCPicturesViewOutterMargin
        picturesViewSize = size
        updateRowHeight()
    }
    /// calculate row height according to cell's content
    /// gray separator 12
    /// margin 12
    /// avatar 34
    /// margin 12
    /// details (calculate here)
    /// pictureView (single image calculate when loading data)
    /// margin 12
    /// buttons bar 35
    
    /// repost weibo also have:
    /// margin 12 * 2
    /// repost details (calculate here)
    func updateRowHeight(){
        let margin: CGFloat = 12
        let iconHeight: CGFloat = 34
        let toolbarHeight: CGFloat = 35
        var height: CGFloat = 0
        let viewSize = CGSize(width: UIScreen.main.bounds.width - 2 * margin, height: CGFloat(MAXFLOAT))
        height = 2 * margin + iconHeight + margin
        if let text = weiboItemAttrText {
            height += text.boundingRect(with: viewSize, options: [.usesLineFragmentOrigin], context: nil).height
        }
        if weiboItem.retweeted_status != nil {
            height += 2 * margin
            
            if let text = repostDetailsAttrText {
                height += text.boundingRect(with: viewSize, options: [.usesLineFragmentOrigin], context: nil).height
            }
        }
        height += picturesViewSize.height
        height += margin
        height += toolbarHeight
        rowHeight = height
    }
}
