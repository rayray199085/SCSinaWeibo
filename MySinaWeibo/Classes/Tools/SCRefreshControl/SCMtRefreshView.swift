//
//  SCMtRefreshView.swift
//  RefreshComponent
//
//  Created by Stephen Cao on 1/4/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit

class SCMtRefreshView: SCRefreshView {

    @IBOutlet weak var earthIcon: UIImageView!
    @IBOutlet weak var buildingIcon: UIImageView!
    @IBOutlet weak var kangarooIcon: UIImageView!
    override var parenViewtHeight : CGFloat{
        didSet{
            var scale = parenViewtHeight / 126
            if scale < 0.2{
                return
            }
            if scale > 1.0{
                scale = 1.0
            }
            kangarooIcon.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    override func awakeFromNib() {
        let buildingImg1 = UIImage(named: "icon_building_loading_1")
        let buildingImg2 = UIImage(named: "icon_building_loading_2")
        buildingIcon.image = UIImage.animatedImage(with: [buildingImg1,buildingImg2] as! [UIImage], duration: 0.5)
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.toValue = -Double.pi * 2
        anim.repeatCount = MAXFLOAT
        anim.duration = 3
        anim.isRemovedOnCompletion = false
        earthIcon.layer.add(anim, forKey: nil)
        let originalY = kangarooIcon.center.y
        kangarooIcon.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        kangarooIcon.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        let kangarooImg1 = UIImage(named: "icon_small_kangaroo_loading_1")
        let kangarooImg2 = UIImage(named: "icon_small_kangaroo_loading_2")
        kangarooIcon.image = UIImage.animatedImage(with: [kangarooImg1,kangarooImg2] as! [UIImage], duration: 0.3)
        let x = kangarooIcon.center.x
        var y = originalY
        y += kangarooIcon.bounds.height * 0.5 - kangarooIcon.bounds.height * 0.2 * 0.5
        y += 4
        kangarooIcon.center = CGPoint(x: x, y: y)
    }
}
