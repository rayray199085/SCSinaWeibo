
//
//  SCWelcomeView.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 27/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit
import SDWebImage

class SCWelcomeView: UIView {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var iconButtonOffset: NSLayoutConstraint!
    class func welcomeView() -> SCWelcomeView{
        let nib = UINib(nibName: "SCWelcomeView", bundle: nil)
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! SCWelcomeView
        v.frame = UIScreen.main.bounds
        return v
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        guard let urlString = SCNetWorkManager.sharedManager.userAccount.avatar_large,
              let url = URL(string: urlString) else {
            return
        }
        iconView.sd_setImage(with: url, placeholderImage: UIImage(named: "avatar_default_big"), options: []) { (image, error, type, url) in
            guard let img = image else{
                return
            }
            // make circle image
            let bgColor = UIColor(displayP3Red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
            self.iconView.image = img.setCircleImage(size: self.iconView.bounds.size, backgroundColor: bgColor, hasFrame: true)
        }
        locationLabel.text = SCNetWorkManager.sharedManager.userAccount.location ?? "China"
        let username = SCNetWorkManager.sharedManager.userAccount.screen_name ?? ""
        welcomeLabel.text = "Welcome Home! \(username)"
    }
    /// view is attached to the window
    override func didMoveToWindow() {
        super.didMoveToWindow()
        // refresh content positions according to their constraints
        self.layoutIfNeeded()
        self.iconButtonOffset.constant = self.bounds.height - 200
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.layoutIfNeeded()
        }) { (hasCompleted) in
            if hasCompleted{
                UIView.animate(withDuration: 1.0, animations: {
                    self.welcomeLabel.alpha = 1.0
                    self.locationLabel.alpha = 1.0
                }, completion: { (hasFinished) in
                    if hasFinished{
                        self.removeFromSuperview()
                    }
                })
            }
        }
    }
}
