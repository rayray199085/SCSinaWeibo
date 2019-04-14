//
//  SCDemoViewController.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 21/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit

class SCDemoViewController: SCBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        naviItem.title = "Number: \(navigationController?.viewControllers.count ?? 0)"
    }
    @objc func goNext(){
        let vc = SCDemoViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension SCDemoViewController{
    override func setupTableView() {
        naviItem.rightBarButtonItem = UIBarButtonItem(title: "Next", fontSize: 16, target: self, action: #selector(goNext))
        super.setupTableView()
    }
}
