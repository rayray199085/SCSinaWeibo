//
//  SCWeiboItemTableViewCell.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 27/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit
import FFLabel
@objc protocol SCWeiboItemTableViewCellDelegate: NSObjectProtocol {
    @objc optional func didSelectURLString(cell: SCWeiboItemTableViewCell,urlString:String)
}
class SCWeiboItemTableViewCell: UITableViewCell {
    weak var delegate: SCWeiboItemTableViewCellDelegate?
    
    var weiboViewModel: SCWeiboItemViewModel?{
        didSet{
            detailsLabel.attributedText = weiboViewModel?.weiboItemAttrText
//            detailsLabel.text = weiboViewModel?.weiboItem.text
            usernameLabel.text = weiboViewModel?.weiboItem.user?.screen_name
            vipView.image = weiboViewModel?.vipIcon
            certificationView.image = weiboViewModel?.vipCertificationIcon
            avatarView.setImage(urlString: weiboViewModel?.weiboItem.user?.profile_image_url, placeholderImage: UIImage(named: "sign-up_avatar_default"),isAvatar: true)
            buttonToolBar.weiboItemViewModel = weiboViewModel
            picturesView.weiboViewModel = weiboViewModel
            repostDetails?.attributedText = weiboViewModel?.repostDetailsAttrText
//            repostDetails?.text = weiboViewModel?.repostDetailsText
            sourceLabel.text = weiboViewModel?.sourceName
            timeLabel.text = weiboViewModel?.weiboItem.createdDate?.sinaDateStringDescription
        }
    }
    
   
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var vipView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var certificationView: UIImageView!
    @IBOutlet weak var detailsLabel: FFLabel!
    @IBOutlet weak var buttonToolBar: SCWeiboItemToolBar!
    @IBOutlet weak var picturesView: SCWeiboItemPictureView!
    
    @IBOutlet weak var repostDetails: FFLabel? // original weibo does not have repost
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // off-screen rendered
        layer.drawsAsynchronously = true
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        detailsLabel.labelDelegate = self
        repostDetails?.labelDelegate = self
    }
}
extension SCWeiboItemTableViewCell: FFLabelDelegate{
    func labelDidSelectedLinkText(label: FFLabel, text: String) {
        if !text.hasPrefix("http://"){
            return
        }
        delegate?.didSelectURLString?(cell: self, urlString: text)
    }
}
