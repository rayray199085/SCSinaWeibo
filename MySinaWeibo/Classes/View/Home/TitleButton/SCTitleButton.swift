//
//  SCTitleButton.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 26/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit

class SCTitleButton: UIButton {
    init(title:String?){
        super.init(frame: CGRect())
        if title == nil{
           setTitle("Home", for: [])
            return
        }else{
            setTitle(title! + " ", for: [])
            setImage(UIImage(named: "navigationbar_arrow_down"), for: [])
            setImage(UIImage(named: "navigationbar_arrow_up"), for: .selected)
        }
        sizeToFit()
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        setTitleColor(UIColor.darkGray, for: [])
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // reset the layout of button
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let titleLabel = titleLabel,
              let imageView = imageView else {
            return
        }
        titleLabel.frame = CGRect(x: 0, y: titleLabel.frame.origin.y, width: titleLabel.bounds.width, height: titleLabel.bounds.height)
        imageView.frame = CGRect(x: titleLabel.bounds.width, y: imageView.frame.origin.y, width: imageView.bounds.width, height: imageView.bounds.height)
    }
}

