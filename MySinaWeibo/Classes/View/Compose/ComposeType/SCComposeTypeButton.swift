//
//  SCComposeTypeButton.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 1/4/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit

class SCComposeTypeButton: UIControl {
    var clsName: String?
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    class func composeTypeButton(imageName: String, title: String)->SCComposeTypeButton{
        let nib = UINib(nibName: "SCComposeTypeButton", bundle: nil)
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! SCComposeTypeButton
        v.iconView.image = UIImage(named: imageName)
        v.titleLabel.text = title
        return v
    }
}
