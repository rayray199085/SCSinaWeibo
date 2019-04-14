//
//  SCOAuthViewController.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 25/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit
import WebKit
import SVProgressHUD

class SCOAuthViewController: UIViewController {
    private lazy var webView = WKWebView()
    override func loadView() {
        view = webView
        view.backgroundColor = UIColor.white
        title = "Sina Weibo Login"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", fontSize: 16, target: self, action: #selector(goBack), isBack: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "AutoFill", fontSize: 16, target: self, action: #selector(autoFill))
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let urlString = "https://api.weibo.com/oauth2/authorize?client_id=\(SCAppKey)&redirect_uri=\(SCRedirectURI)"
        guard let url = URL(string: urlString) else {
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    //Mark: - left button observer
    @objc private func goBack(){
        SVProgressHUD.dismiss()
        dismiss(animated: true, completion: nil)
    }
    //Mark: - automatically fill account number and password
    @objc private func autoFill(){
        // prepare js
        // FIXME: add your own username and password can auto fill in the blanks
        let js = "document.getElementById('userId').value = 'xxx@gmail.com'; " +
                 "document.getElementById('passwd').value = 'xxxxxxxxxx';"
        // webView execute js
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
}

// MARK: - WKNavigationDelegate
extension SCOAuthViewController: WKNavigationDelegate{
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.url?.absoluteString.hasPrefix(SCRedirectURI) == false{
            decisionHandler(.allow)
            return
        }
        if navigationAction.request.url?.query?.hasPrefix("code=") == false{
            decisionHandler(.cancel)
            goBack()
            return
        }
        let codeUrl = (navigationAction.request.url?.query)! as NSString
        let code = codeUrl.substring(from: "code=".count)
        SCNetWorkManager.sharedManager.getAccessToken(code: code) { (isSuccess) in
            if !isSuccess{
                SVProgressHUD.showInfo(withStatus: "Fail to connect to the Internet.")
            }else{
                NotificationCenter.default.post(name: NSNotification.Name(SCUserLoginSuccessfullyNotification), object: nil)
                self.goBack()
            }
        }
        decisionHandler(.cancel)
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        SVProgressHUD.show()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        SVProgressHUD.dismiss()
    }
}
