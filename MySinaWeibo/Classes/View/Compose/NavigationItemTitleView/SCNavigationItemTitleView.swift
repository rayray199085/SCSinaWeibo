//
//  SCNavigationItemTitleView.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 5/4/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit

class SCNavigationItemTitleView: UIView {
    @IBOutlet weak var usernameLabel: UILabel!
    
    class func titleView(username: String)->SCNavigationItemTitleView{
        let nib = UINib(nibName: "SCNavigationItemTitleView", bundle: nil)
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! SCNavigationItemTitleView
        v.usernameLabel.text = username
        return v
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
