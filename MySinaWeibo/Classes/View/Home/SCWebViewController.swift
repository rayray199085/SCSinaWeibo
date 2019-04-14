//
//  SCWebViewController.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 4/4/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit
import WebKit
import SVProgressHUD

class SCWebViewController: SCBaseViewController {
    private lazy var webView: WKWebView = WKWebView(frame: UIScreen.main.bounds)
    var urlString: String?{
        didSet{
            guard let urlString = urlString,
                  let url = URL(string: urlString) else{
                return
            }
            webView.load(URLRequest(url: url))
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        // Do any additional setup after loading the view.
    }
    override func setupTableView() {
        naviItem.title = "Web Page"
        view.insertSubview(webView, belowSubview: naviBar)
        webView.scrollView.bounces = false
        webView.scrollView.contentInset.top = naviBar.bounds.height - 20
        webView.backgroundColor = UIColor.white
    }
}
extension SCWebViewController : WKNavigationDelegate{
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        SVProgressHUD.show()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        SVProgressHUD.dismiss()
    }
}
