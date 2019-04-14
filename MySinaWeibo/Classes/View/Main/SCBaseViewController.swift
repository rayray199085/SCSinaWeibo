//
//  SCBaseViewController.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 21/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit
/// set up base controller
class SCBaseViewController: UIViewController{
    var tableView : UITableView?
    var visitorInfoDictionary: [String:String]?
    var refreshControl : SCRefreshControl?
    var shouldPullUp = false
    lazy var naviBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 64))
    lazy var naviItem = UINavigationItem()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        SCNetWorkManager.sharedManager.userlogon ? loadData() : ()
        NotificationCenter.default.addObserver(
            self, selector: #selector(loginSuccessfully), name: NSNotification.Name(SCUserLoginSuccessfullyNotification), object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: SCUserLoginSuccessfullyNotification), object: nil)
    }
    /// set title to the override navigation item's title
    override var title: String?{
        didSet{
            naviItem.title = title
        }
    }
    /// for subClass to override
    @objc func loadData(){
        refreshControl?.endRefreshing()
    }
}
/// visitorView observer methods for login and sign up
extension SCBaseViewController{
    @objc private func loginSuccessfully(n : Notification){
        naviItem.leftBarButtonItem = nil
        naviItem.rightBarButtonItem = nil
        view = nil
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: SCUserLoginSuccessfullyNotification), object: nil)
    }
    
    @objc private func login(){
        print("user login")
        NotificationCenter.default.post(name: NSNotification.Name(SCUserShouldLoginNotification), object: nil)
    }
    @objc private func signUp(){
        print("user sign up")
    }
}
/// set up base controller view
extension SCBaseViewController{
    private func setupUI(){
        setupNavigationBar()
        SCNetWorkManager.sharedManager.userlogon ? setupTableView() : setupVisitorView()
    }
    private func setupNavigationBar(){
        naviBar.barTintColor = UIColor(hexValue: 0xF6F6F6)
        naviBar.items = [naviItem]
        naviBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.darkGray]
        naviBar.tintColor = UIColor.orange
        view.addSubview(naviBar)
    }
    private func setupVisitorView(){
        let visitorView = SCvisitorView(frame: view.bounds)
        visitorView.visitorInfo = visitorInfoDictionary
        visitorView.loginButton.addTarget(self, action: #selector(login), for: UIControl.Event.touchUpInside)
        visitorView.registrationButton.addTarget(self, action: #selector(signUp), for: UIControl.Event.touchUpInside)
        view.insertSubview(visitorView, belowSubview: naviBar)
        
        naviItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Up", style: UIBarButtonItem.Style.plain, target: self, action: #selector(signUp))
        naviItem.rightBarButtonItem = UIBarButtonItem(title: "Login", style: UIBarButtonItem.Style.plain, target: self, action: #selector(login))
    }
    // subClass override this method
   @objc func setupTableView(){
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        let offsetTop = naviBar.bounds.height - 20
        let offsetBottom = tabBarController?.tabBar.bounds.height ?? 49
        let edgeInsets = UIEdgeInsets(top: offsetTop, left: 0, bottom: offsetBottom, right: 0)
        tableView?.contentInset = edgeInsets
        tableView?.scrollIndicatorInsets = edgeInsets
        view.insertSubview(tableView ?? UITableView(), belowSubview: naviBar)
        // setup refresh control and add it to the tableView
        refreshControl = SCRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView?.addSubview(refreshControl ?? UIRefreshControl())
    
    }
}
/// set up base controllor tableView delegate
extension SCBaseViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let row = indexPath.row
        // let currentSection == indexPath.section
        let section = tableView.numberOfSections - 1
        if row < 0 || section < 0{
            return
        }
        let rowCount = tableView.numberOfRows(inSection: section)
        // && currentSection == section
        if row == (rowCount - 1) && !shouldPullUp{
            shouldPullUp = true
            loadData()
        }
    }
}
