//
//  SCHomeViewController.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 21/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit

// original weibo reuseIndentifier
private let originalReuseIndentifier = "originalCellId"
// repost weibo reuseIndentifier
private let repostReuseIndentifier = "repostCellId"
class SCHomeViewController: SCBaseViewController {
//    private lazy var statusList = [String]()
    private lazy var weiboItemListViewModel = SCWeiboItemListViewModel()
    @objc func showFriends(){
        let vc = SCDemoViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    override func loadData() {
        refreshControl?.beginRefreshing()
        weiboItemListViewModel.loadWeiboItem(pullUp: self.shouldPullUp) { (isSuccess, shouldRefreshTable) in
            // after completion of loading data
            self.shouldPullUp = false
            self.refreshControl?.endRefreshing()
            if shouldRefreshTable{
                self.tableView?.reloadData()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(browsePhoto), name: NSNotification.Name(SCPhotoBrowserForWeiboCellNotification), object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(SCPhotoBrowserForWeiboCellNotification), object: nil)
    }
    @objc private func browsePhoto(notification: Notification){
        guard let userInfo = notification.userInfo,
            let selectedIndex = userInfo[SCPhotoBrowserForWeiboCellSelectedImageIndex] as? Int,
            let picUrls = userInfo[SCPhotoBrowserForWeiboCellSelectedImageURLs] as? [String] else {
            return
        }
        let photoBrowser = HZPhotoBrowser()
        photoBrowser.isFullWidthForLandScape = true
        photoBrowser.isNeedLandscape = true
        photoBrowser.currentImageIndex = Int32(selectedIndex)
        photoBrowser.imageArray = picUrls
        photoBrowser.show()
    }
}
/// set up UI
extension SCHomeViewController{
   override func setupTableView() {
      super.setupTableView()
        naviItem.leftBarButtonItem = UIBarButtonItem(title: "Friends", fontSize: 16, target: self, action: #selector(showFriends))
        tableView?.register(UINib(nibName: "SCWeiboItemNormalTableViewCell", bundle: nil), forCellReuseIdentifier: originalReuseIndentifier)
        tableView?.register(UINib(nibName: "SCWeiboItemRepostTableViewCell", bundle: nil), forCellReuseIdentifier: repostReuseIndentifier)
        // set table view row height
//        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 300
        tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        setupNaviItemTitle()
    }
    
    /// set up navigationItem title
    private func setupNaviItemTitle(){
        let title = SCNetWorkManager.sharedManager.userAccount.screen_name
        let button = SCTitleButton(title: title)
        naviItem.titleView = button
        button.addTarget(self, action: #selector(clickTitleButton), for: UIControl.Event.touchUpInside)
    }
    @objc private func clickTitleButton(button : UIButton){
        button.isSelected = !button.isSelected
    }
}
/// tableView delegate functions
extension SCHomeViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weiboItemListViewModel.weiboItemList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let weiboViewModel = weiboItemListViewModel.weiboItemList[indexPath.row]
        let reuseIdentifier = (weiboViewModel.weiboItem.retweeted_status != nil) ? repostReuseIndentifier : originalReuseIndentifier
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? SCWeiboItemTableViewCell else{
            return UITableViewCell()
        }
        cell.weiboViewModel = weiboViewModel
        cell.delegate = self
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         let weiboViewModel = weiboItemListViewModel.weiboItemList[indexPath.row]
         return weiboViewModel.rowHeight
    }    
}

// MARK: - SCWeiboItemTableViewCellDelegate
extension SCHomeViewController: SCWeiboItemTableViewCellDelegate{
    func didSelectURLString(cell: SCWeiboItemTableViewCell, urlString: String) {
        let vc = SCWebViewController()
        vc.urlString = urlString
        navigationController?.pushViewController(vc, animated: true)
    }
}
