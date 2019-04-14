//
//  SCEmoticonsItem.swift
//  TestMixWordsAndImage
//
//  Created by Stephen Cao on 3/4/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit

class SCEmoticonsItem: NSObject {
    @objc var type = false
    @objc var chs: String?
    @objc var png: String?
    @objc var code: String?{
        didSet{
            emojiString = code?.getEmojiFromHexInt32CodeString()
        }
    }
    @objc var emojiString: String?
    @objc var directory: String?
    @objc var usedTimes: Int = 0
    @objc var image:UIImage?{
        if type{
            return nil
        }
        guard let path = Bundle.main.path(forResource: "Emoticons.bundle", ofType: nil),
            let bundle = Bundle(path: path),
            let directory = directory,
            let imageName = png else {
            return nil
        }
        let imagePath = "\(directory)/\(imageName)"
        return UIImage(named: imagePath, in: bundle, compatibleWith: nil)
    }
    override var description: String{
        return yy_modelDescription()
    }
    func imageText(font: UIFont)->NSAttributedString{
        guard let img = image else{
            return NSAttributedString(string: "")
        }
        let attachment = SCTextAttachment()
        attachment.image = img
        let height = font.lineHeight
        attachment.bounds = CGRect(x: 0, y: -height * 0.25, width: height, height: height)
        attachment.textString = chs
        let imageAttrText = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
        imageAttrText.addAttributes([NSAttributedString.Key.font : font], range: NSRange(location: 0, length: 1))
        return imageAttrText
    }
}
