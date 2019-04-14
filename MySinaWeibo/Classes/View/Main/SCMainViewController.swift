//
//  SCMainViewController.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 21/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit
import SVProgressHUD

class SCMainViewController: UITabBarController {
    // periodically detect unread weibo items
    private var timer :Timer?
    private lazy var composeButton = UIButton.imageButton(
        withImageName: "tabbar_compose_icon_add",
        andBackgroundImageName: "tabbar_compose_button")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildControllers()
        setupComposeButton()
        setupTimer()
        // setup new feature view
        setupNewFeatureView()
        // avoid tab bar items icon lagging between the gap of jumpping
        // from one controller to another
        tabBar.isTranslucent = false
        delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(userLogin), name: NSNotification.Name(rawValue: SCUserShouldLoginNotification), object: nil)
    }
    /// notification observer
    @objc private func userLogin(n : Notification){
        var delay = DispatchTime.now()
        if n.object != nil{
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.gradient)
            SVProgressHUD.showInfo(withStatus: "Access token has expired, please Login again.")
            delay = DispatchTime.now() + 2
        }
        DispatchQueue.main.asyncAfter(deadline: delay) {
            let nav = UINavigationController(rootViewController: SCOAuthViewController())
            self.present(nav, animated: true, completion: nil)
        }
    }
    deinit {
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: SCUserShouldLoginNotification), object: nil)
        timer?.invalidate()
    }
    //MARK: - Compose Button Observer
    @objc private func composeButtonObserver(){
      
        // check whether login
        if !SCNetWorkManager.sharedManager.userlogon || SCNetWorkManager.sharedManager.userAccount.screen_name == nil{
            return
        }
        
        let composeView = SCComposeTypeView.composeTypeView()
        composeView.show { [weak composeView](clsName) in
            if clsName == ""{
                composeView?.removeFromSuperview()
                return
            }
            guard let cls = NSClassFromString(Bundle.main.nameSpace + "." + clsName) as? SCComposeIdeaViewController.Type else{
                return
            }
            let viewController = cls.init()
            let nav = UINavigationController(rootViewController: viewController)
            self.present(nav, animated: true, completion: {
                composeView?.removeFromSuperview()
            })
        }
    }
}

// MARK: - new feature view setup
extension SCMainViewController{
    private func setupNewFeatureView(){
        if !SCNetWorkManager.sharedManager.userlogon{
            return 
        }
        // check whether the current version is the latest one
        
        // if yes show new feature view, otherwise display welcome view
        let v = isNewVersion ? SCNewFeatureView.newFeatureView() : SCWelcomeView.welcomeView()
        // add view to a parent view
        view.addSubview(v)
    }
    private var isNewVersion :Bool{
        // get current version string
        let currentVersionString = Bundle.main.currentVersion
        // get saved version string
        let savedString = UserDefaults.standard.string(forKey: "version") ?? ""
        // update saved version string
        UserDefaults.standard.set(currentVersionString, forKey: "version")
        // compare two strings
        return currentVersionString != savedString
    }
}
//Mark: - tab bar delegate UITabBarControllerDelegate
extension SCMainViewController: UITabBarControllerDelegate{
    
    /// will do the selection
    ///
    /// - Parameters:
    ///   - tabBarController: tabBarController
    ///   - viewController: destination controller
    /// - Returns: whether jump to destination controller
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // current index
        let index = (children as NSArray).index(of: viewController)
        // select the home controller
        if selectedIndex == 0 && index == selectedIndex{
            let naviController = children.first as! UINavigationController
            let homeController = naviController.viewControllers.first as! SCHomeViewController
            // roll to top of tableView
            homeController.tableView?.setContentOffset(CGPoint(x: 0, y: -170), animated: false)
            // delay make sure that roll to head firstly then reload data
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                homeController.loadData()
            }
            // clear tab bar item badge number
            homeController.tabBarItem.badgeValue = nil
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        return !viewController.isMember(of: UIViewController.self)
    }
}
//Mark: - timer
extension SCMainViewController{
    private func setupTimer(){
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true, block: { (timer) in
            SCNetWorkManager.sharedManager.unreadCount(completion: { (count) in
                if !SCNetWorkManager.sharedManager.userlogon{
                    return
                }
                self.tabBar.items?.first?.badgeValue = count > 0 ? "\(count)" : nil
                // set application badge number
                UIApplication.shared.applicationIconBadgeNumber = count
            })
        })
    }
}
//Mark: - setup UI
extension SCMainViewController{
    //MARK: - Compose Button setup
    private func setupComposeButton(){
        tabBar.addSubview(composeButton)
        guard let count = viewControllers?.count else {
            return
        }
        let width = tabBar.bounds.size.width / CGFloat(count)
        // |---2 * width---- button.width ---2 * width---|
        composeButton.frame = tabBar.bounds.insetBy(dx: 2 * width, dy: 0)
        composeButton.addTarget(self, action: #selector(composeButtonObserver), for: .touchUpInside)
    }
    // this controller and its sub-controllers' screen direction can only be portrait
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait  
    }
    
    /// Steps to load data
    /// 1. check document directory to get latest data in json
    /// 2. if 1 fails, get the default data in bundle
    /// 3. transform the data to be an array with dictionaries
    /// 4. create controllers according to the information of the relevant dictionary
    private func setupChildControllers(){
        let docDir = NSString.getDocumentDirectory()
        let jsonPath = (docDir as NSString).appendingPathComponent("main.json")
        var netData = NSData(contentsOfFile: jsonPath)
        if netData == nil{
            let path = Bundle.main.path(forResource: "main.json", ofType: nil)
            netData = NSData(contentsOfFile: path!)
        }
        guard let array = ((try? JSONSerialization.jsonObject(with: netData! as Data, options: []) as? [[String:Any]])) else {
            return
        }
        var arrayM = [UIViewController]()
        for dict in array{
           arrayM.append( controller(dict: dict))
        }
        viewControllers = arrayM
    }
    private func controller(dict : [String:Any])-> UIViewController{
        guard let className = dict["className"] as? String,
              let title = dict["title"] as? String,
              let imageName = dict["imageName"] as? String,
              let cls = NSClassFromString(Bundle.main.nameSpace + "." + className) as? SCBaseViewController.Type,
              let visitorDict = dict["visitorInfo"] as? [String: String]
            else {
            return UIViewController()
        }
        let viewController = cls.init()
        viewController.title = title
        viewController.tabBarItem.image = UIImage(named: "tabbar_" + imageName)
        viewController.tabBarItem.selectedImage = UIImage(named: "tabbar_" + imageName + "_selected")?.withRenderingMode(.alwaysOriginal)
        viewController.tabBarItem.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor : UIColor.orange],
            for: .highlighted)
        viewController.tabBarItem.setTitleTextAttributes(
            [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)],
            for: .normal)
        viewController.visitorInfoDictionary = visitorDict
        
        let navigationController = SCNavigationViewController.init(rootViewController: viewController)
        return navigationController
    }
}
