//
//  SCNavigationViewController.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 21/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit

class SCNavigationViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isHidden = true
    }
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        /// hide tab bar 
        if viewControllers.count > 0{
            viewController.hidesBottomBarWhenPushed = true
            if let vc = viewController as? SCBaseViewController{
                var title = "Back"
                if viewControllers.count == 1{
                    title = viewControllers.first?.title ?? "Back"
                }
                vc.naviItem.leftBarButtonItem = UIBarButtonItem(title: title, fontSize: 16, target: self, action: #selector(goBack),isBack:true)
            }
        }
        super.pushViewController(viewController, animated: animated)
    }
    @objc func goBack() -> () {
        popViewController(animated: true)
    }

}
