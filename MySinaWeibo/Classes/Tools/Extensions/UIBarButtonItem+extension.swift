//
//  UIBarButtonItem+extension.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 21/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit

extension UIBarButtonItem{
    /// init barButtonItem with font size and title
    convenience init(title: String, fontSize :CGFloat, target: Any?, action: Selector, isBack :Bool = false){
        let button = UIButton.textButton(withTitle: title, andWithFontSize: fontSize, andWithNormalColor: UIColor.darkGray, andWithHighlight: UIColor.orange)
        button.addTarget(target, action: action, for: .touchUpInside)
        if isBack{
            button.setImage(UIImage(named: "navigationbar_back_withtext"), for: .normal)
            button.setImage(UIImage(named: "navigationbar_back_withtext_highlighted"), for: .highlighted)
            button.sizeToFit()
        }
        self.init(customView: button)
    }
}
