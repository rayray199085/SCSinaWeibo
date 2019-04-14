//
//  SCComposeIdeaViewController.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 2/4/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit
import SVProgressHUD

class SCComposeIdeaViewController: UIViewController {
    private lazy var emoticonView: SCEmoticonInputView = SCEmoticonInputView.inputView { [weak self](item) in
        self?.insertEmoticon(item: item)
    }
    private lazy var placeholderLabel : UILabel = UILabel()
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var textView: UITextView!
    private lazy var sendButton: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitle("Send", for: UIControl.State.normal)
        btn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        btn.setTitleColor(UIColor.gray, for: UIControl.State.disabled)
        btn.setBackgroundImage(UIImage(named: "common_button_orange"), for: UIControl.State.normal)
        btn.setBackgroundImage(UIImage(named: "common_button_orange_highlighted"), for: UIControl.State.highlighted)
         btn.setBackgroundImage(UIImage(named: "common_button_white_disable"), for: UIControl.State.disabled)
        btn.sizeToFit()
        btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    deinit {
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
}
private extension SCComposeIdeaViewController{
    func setupUI(){
        view.backgroundColor = UIColor.white
        textView.delegate = self
        let placeholderString = "What's on your mind?, \(SCNetWorkManager.sharedManager.userAccount.screen_name ?? "")"
        placeholderLabel.setPlaceholderLabel(textView: textView, placeholderString: placeholderString)
        textView.addSubview(placeholderLabel)
        textView.becomeFirstResponder()
        setupNavigationBar()
        setupToolbarButtons()
    }
    func setupNavigationBar(){
         navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", fontSize: 16, target: self, action: #selector(goBack), isBack: false)
         navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: sendButton)
         sendButton.isEnabled = false
         sendButton.addTarget(self, action: #selector(sendWeibo), for: UIControl.Event.touchUpInside)
         let titleView = SCNavigationItemTitleView.titleView(username: SCNetWorkManager.sharedManager.userAccount.screen_name ?? "")
         navigationItem.titleView = titleView    
    }
    func setupToolbarButtons(){
        let itemSettings = [["imageName":"compose_toolbar_picture"],["imageName":"compose_mentionbutton_background"],["imageName":"compose_trendbutton_background"],
            ["imageName":"compose_emoticonbutton_background", "actionName":"emoticonKeyboard"],
            ["imageName":"compose_add_background"]]
        var buttonItems = [UIBarButtonItem]()
        for imageItem in itemSettings{
            if let normalImageName = imageItem["imageName"]{
                let highlightedImageName = "\(normalImageName)_highlighted"
                let button = UIButton.imageButton(withNormalImageName: normalImageName, andWithHighlightedImageName: highlightedImageName)
                if let functionName = imageItem["actionName"]{
                     button.addTarget(self, action: Selector(functionName), for: UIControl.Event.touchUpInside)
                }
                buttonItems.append(UIBarButtonItem(customView: button))
                buttonItems.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil))
            }
        }
        buttonItems.removeLast()
        toolbar.items = buttonItems
    }
}

// MARK: - navigation bar buttons observer
private extension SCComposeIdeaViewController{
    @objc func goBack(){
        dismiss(animated: true, completion: nil)
        view.endEditing(true)
        SVProgressHUD.dismiss()
    }
    @objc func sendWeibo(){
        // FIXME: temp test sending image
        let image = UIImage(named: "icon_small_kangaroo_loading_1")
        SCNetWorkManager.sharedManager.postWeibo(textContent: emoticonText, image: image) { (res, isSuccess) in
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.gradient)
            SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
            if let errorMessage = res["error"] as? String{
                if errorMessage.count > 0{
                    SVProgressHUD.showError(withStatus: "Please try again later.")
                    return
                }
            }
            SVProgressHUD.showInfo(withStatus: "Send successfully!")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
                self.goBack()
            })
        }
    }
}


// MARK: - keyboard observer
private extension SCComposeIdeaViewController{
    @objc func keyboardWillShow(notification: Notification){
        updateToolbarPosition(notification: notification)
    }
    @objc func keyboardWillHide(notification: Notification){
        updateToolbarPosition(notification: notification)
    }
    func updateToolbarPosition(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber{
            let keyboardRect = keyboardFrame.cgRectValue
            toolbarBottomConstraint.constant = -keyboardRect.height
            UIView.animate(withDuration: duration.doubleValue) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
extension SCComposeIdeaViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        sendButton.isEnabled = !emoticonText.isEmpty
        placeholderLabel.isHidden = !emoticonText.isEmpty
    }
}

// MARK: - emoji keyboard
private extension SCComposeIdeaViewController{
    @objc func emoticonKeyboard(){
        textView.inputView = textView.inputView == nil ? emoticonView :nil
        textView.reloadInputViews()
    }
    func insertEmoticon(item: SCEmoticonsItem?){
        guard let item = item else{
            textView.deleteBackward()
            return
        }
        if let emoji = item.emojiString,
            let textRange = textView.selectedTextRange{
            textView.replace(textRange, withText: emoji)
            return
        }
        
        let attrStrM = NSMutableAttributedString(attributedString: textView.attributedText)
        
        attrStrM.replaceCharacters(in: textView.selectedRange, with: item.imageText(font: textView.font!))
        // record cursor position
        let previousRange = textView.selectedRange
        textView.attributedText = attrStrM
        // update cursor position
        textView.selectedRange = NSRange(location: previousRange.location + 1, length: 0)
        textView.delegate?.textViewDidChange?(textView)
    }
    
    /// turn attribute text into string text
    var emoticonText: String{
        guard let attrStr = textView.attributedText else {
            return ""
        }
        var res = String()
        attrStr.enumerateAttributes(in: NSRange(location: 0, length: attrStr.length), options: [], using: { (dict, range, _) in
            if let attachment = dict[NSAttributedString.Key.attachment] as? SCTextAttachment{
                res += attachment.textString ?? ""
            }else{
                let subString = (attrStr.string as NSString).substring(with: range)
                res += subString
            }
        })
        return res
    }
}
