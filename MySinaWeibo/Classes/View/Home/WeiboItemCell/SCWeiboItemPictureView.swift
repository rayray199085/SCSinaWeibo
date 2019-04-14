//
//  SCWeiboItemPictureView.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 28/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit

class SCWeiboItemPictureView: UIView {
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    var weiboViewModel: SCWeiboItemViewModel? {
        didSet{
            calculatePictureViewSize()
            picUrls = weiboViewModel?.picURLs
        }
    }
    
    /// adjust single picture imageView size
    private func calculatePictureViewSize() {
        if weiboViewModel?.picURLs?.count == 1 {
            let viewSize = weiboViewModel?.picturesViewSize ?? CGSize()
            let v = subviews[0]
            v.frame = CGRect(x: 0, y: SCPicturesViewOutterMargin, width: viewSize.width, height: viewSize.height - SCPicturesViewOutterMargin)
        }else{
            let v = subviews[0]
            v.frame = CGRect(x: 0, y: SCPicturesViewOutterMargin, width: SCPictureViewImageWidth, height: SCPictureViewImageWidth)
        }
        heightConstraint.constant = weiboViewModel?.picturesViewSize.height ?? 0
    }

    private var picUrls: [SCPictureItem]? {
        didSet{
            for v in subviews {
                v.isHidden = true
            }
            var index = 0
            for url in picUrls ?? [] {
                let iv = subviews[index] as! UIImageView
                if index == 1 && picUrls?.count == 4 {
                    index += 1
                }
                iv.setImage(urlString: url.thumbnail_pic, placeholderImage: UIImage(named: "empty_picture"), isAvatar: false)
                iv.subviews[0].isHidden = !(url.thumbnail_pic ?? "").hasSuffix(".gif")
                iv.isHidden = false
                index += 1
            }
        }
    }

    override func awakeFromNib() {
        setupUI()
    }
    
    /// tap gesture observer
    ///
    /// - Parameter recoginizer: UITapGestureRecognizer
    @objc private func tapImageView(tap: UITapGestureRecognizer){
        guard let iv = tap.view as? UIImageView,
            let picUrls = picUrls else{
            return
        }
        let imagesUrls = (picUrls as NSArray).value(forKey: "large_pic") as! [String]
        var visibleViews = [UIImageView]()
        for v in subviews as! [UIImageView]{
            if !v.isHidden{
                visibleViews.append(v)
            }
        }
        var selectedIndex = iv.tag
        if iv.tag >= 3 && visibleViews.count == 4{
            selectedIndex -= 1
        }
       
        var userInfoDict = [AnyHashable:Any]()
        userInfoDict[SCPhotoBrowserForWeiboCellSelectedImageIndex] = selectedIndex
        userInfoDict[SCPhotoBrowserForWeiboCellSelectedImageURLs] = imagesUrls
        userInfoDict[SCPhotoBrowserForWeiboCellSelectedImageVisibleImageViews] = visibleViews
        NotificationCenter.default.post(name: NSNotification.Name(SCPhotoBrowserForWeiboCellNotification), object: self, userInfo: userInfoDict)
    }
}

private extension SCWeiboItemPictureView {

    func setupUI(){
        clipsToBounds = true
        for index in 0..<9{
            let x = CGFloat(index % 3) *
                (SCPicturesViewInnerMargin + SCPictureViewImageWidth)
            let y = SCPicturesViewOutterMargin +
                CGFloat(index / 3) *
                (SCPictureViewImageWidth + SCPicturesViewInnerMargin)
            let iv = UIImageView(frame: CGRect(x: x, y: y, width: SCPictureViewImageWidth, height: SCPictureViewImageWidth))
            iv.isUserInteractionEnabled = true
            iv.tag = index
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapImageView))
            tap.numberOfTapsRequired = 1
            iv.addGestureRecognizer(tap)
            addSubview(iv)
            addGifIconView(iv: iv)
        }
    }
    
    /// add gif icon to imageView
    ///
    /// - Parameter iv: imageView
    func addGifIconView(iv: UIImageView){
        let gifIconView = UIImageView(image: UIImage(named: "timeline_image_gif"))
        iv.addSubview(gifIconView)
        
        gifIconView.translatesAutoresizingMaskIntoConstraints = false
        
        iv.addConstraint(NSLayoutConstraint(item: gifIconView, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: iv, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0))
        
        iv.addConstraint(NSLayoutConstraint(item: gifIconView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: iv, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0))
    }
}
