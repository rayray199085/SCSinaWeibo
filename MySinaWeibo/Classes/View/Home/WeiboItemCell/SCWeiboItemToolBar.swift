//
//  SCWeiboItemToolBar.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 28/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit
import SCLAlertView

class SCWeiboItemToolBar: UIView {
    var weiboItemViewModel: SCWeiboItemViewModel?{
        didSet{
            repostButton.setTitle(weiboItemViewModel?.repostString, for: [])
            commentButton.setTitle(weiboItemViewModel?.commentString, for: [])
            likeButton.setTitle(weiboItemViewModel?.likeString, for: [])
        }
    }
    @IBOutlet weak var repostButton:UIButton!
    @IBOutlet weak var commentButton:UIButton!
    @IBOutlet weak var likeButton:UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    /// repost button observer
    ///
    /// - Parameter sender: prepare to repost a weibo
    @IBAction func repostWeibo(_ sender: UIButton) {
        guard let weiboID = weiboItemViewModel?.weiboItem.id else {
            return
        }
        let alert = SCLAlertView()
        let txt = alert.addTextField("What's on your mind?, \(SCNetWorkManager.sharedManager.userAccount.screen_name ?? "")")
        alert.addButton("Send") {
            SCNetWorkManager.sharedManager.repostWeibo(weiboID: weiboID, textContent: txt.text ?? "") { (res) in
                if let errorMessage = res["error"] as? String{
                    if errorMessage.count > 0{
                        print(errorMessage)
                        return
                    }
                }
                print(res)
            }
        }
        alert.showEdit("Repost Weibo", subTitle: "Share your feelings...")
    }
    
}
