//
//  SCEmoticonTipsView.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 10/4/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit
import pop

/// emoticon keyboard key tips
class SCEmoticonTipsView: UIImageView {
    var fontSize:CGFloat?
    var emoticonsItem:SCEmoticonsItem?{
        didSet{
            guard let emoticonsItem = emoticonsItem else{
                return
            }
            emojiIconiButton.setBackgroundImage(nil, for: [])
            emojiIconiButton.setTitle("", for: [])
            // image
            emojiIconiButton.setBackgroundImage(emoticonsItem.image, for: [])
            // emoji
            emojiIconiButton.setTitle(emoticonsItem.emojiString, for: [])
            emojiIconiButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize ?? 14)
            
            emojiIconiButton.sizeToFit()
            emojiIconiButton.center.x = bounds.width * 0.5
            emojiIconiButton.center.y = bounds.height * 0.3
            
            let anim :POPSpringAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            anim.fromValue = bounds.height * 0.6
            anim.toValue = bounds.height * 0.3
            anim.springBounciness = 20
            anim.springSpeed = 20
            emojiIconiButton.layer.pop_add(anim, forKey: nil)
        }
    }
    private lazy var emojiIconiButton = UIButton()
    init(){
        let tipsImage = UIImage(named: "emoticon_keyboard_magnifier")
        super.init(image: tipsImage)
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        addSubview(emojiIconiButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
