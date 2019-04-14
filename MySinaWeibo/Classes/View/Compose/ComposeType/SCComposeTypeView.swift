//
//  SCComposeTypeView.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 1/4/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit
import pop

/// View for displaying composition types
class SCComposeTypeView: UIView {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var returnXConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeXConstraint: NSLayoutConstraint!
    @IBOutlet weak var returnButton: UIButton!
    private weak var leftView: UIView?
    private weak var rightView: UIView?
    private var completion:((_ clsName:String)->())?
    private let buttonsInfo = [["imageName":"tabbar_compose_idea","title":"Idea","clsName":"SCComposeIdeaViewController"],["imageName":"tabbar_compose_photo","title":"Photo"],["imageName":"tabbar_compose_weibo","title":"Weibo"],["imageName":"tabbar_compose_lbs","title":"Check-in"],["imageName":"tabbar_compose_review","title":"Comment"],["imageName":"tabbar_compose_more","title":"More"],["imageName":"tabbar_compose_friend","title":"Friends"],["imageName":"tabbar_compose_voice","title":"Voice"],["imageName":"tabbar_compose_music","title":"Music"],["imageName":"tabbar_compose_shooting","title":"Camera"]]
    
    class func composeTypeView()->SCComposeTypeView{
        let nib = UINib(nibName: "SCComposeTypeView", bundle: nil)
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! SCComposeTypeView
        v.frame = UIScreen.main.bounds
        v.setupUI()
        return v
    }

    func show(completion:@escaping (_ clsName:String)->()) {
        guard let parentView = UIApplication.shared.keyWindow?.rootViewController?.view else{
            return
        }
        parentView.addSubview(self)
        // start animation
        showCurrentView()
        self.completion = completion
    }
    
    @objc func clickFunctionButton(_ sender: SCComposeTypeButton){
        if sender.tag == 5{
            scrollView.setContentOffset(CGPoint(x: scrollView.bounds.width, y: 0), animated: true)
            returnButton.isHidden = false
            closeXConstraint.constant = scrollView.bounds.width / 6
            returnXConstraint.constant = -scrollView.bounds.width / 6
            UIView.animate(withDuration: 0.25) {
                self.layoutIfNeeded()
            }
            return
        }
        let currentSubView = getCurrentSubView()
        for button in currentSubView.subviews{
            let anim :POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
            //selected button become larger
            if button.tag == sender.tag{
                anim.toValue = NSValue(cgPoint: CGPoint(x: 2.0, y: 2.0))
            }else{
                anim.toValue = NSValue(cgPoint: CGPoint(x: 0.2, y: 0.2))
            }
            anim.duration = 0.5
            button.pop_add(anim, forKey: nil)
        }
        let alphaAnim :POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        alphaAnim.fromValue = 1
        alphaAnim.toValue = 0.2
        alphaAnim.duration = 0.5
        currentSubView.pop_add(alphaAnim, forKey: nil)
        alphaAnim.completionBlock = {(_,_)in
            self.completion!(sender.clsName ?? "")
        }
    }
    
    @IBAction func clickOffButton(_ sender: Any) {
        hideButtons()
//        removeFromSuperview()
    }
    @IBAction func clickReturn(_ sender: UIButton) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        closeXConstraint.constant = 0
        returnXConstraint.constant = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.layoutIfNeeded()
            self.returnButton.alpha = 0
        }) { (_) in
            self.returnButton.isHidden = true
            self.returnButton.alpha = 1
        }
    }
}
private extension SCComposeTypeView{
    func setupUI(){
        layoutIfNeeded()
        let scrollViewWidth = scrollView.bounds.width
        let scrollViewHeight = scrollView.bounds.height
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: scrollViewWidth, height: scrollViewHeight))
        let rightView = UIView(frame: CGRect(x: scrollViewWidth, y: 0, width: scrollViewWidth, height: scrollViewHeight))
        self.leftView = leftView
        self.rightView = rightView
        scrollView.contentSize = CGSize(width: scrollViewWidth * 2, height: 0)
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = false
        addButtons(parentView: leftView, startIndex: 0, endIndex: 6)
        addButtons(parentView: rightView, startIndex: 6, endIndex: 10)
        scrollView.addSubview(leftView)
        scrollView.addSubview(rightView)
    }
    
    /// add buttons to scrollView's subViews
    ///
    /// - Parameters:
    ///   - parentView: views in scrollView
    ///   - startIndex: buttonsInfo start index
    ///   - endIndex: buttonsInfo end index
    func addButtons(parentView: UIView, startIndex: Int,endIndex: Int){
        for index in startIndex..<endIndex{
            let name = buttonsInfo[index]["imageName"]!
            let title = buttonsInfo[index]["title"]!
            let button = SCComposeTypeButton.composeTypeButton(imageName: name, title: title)
            let width = button.bounds.width
            let height = button.bounds.height
            let marginX = (scrollView.bounds.width - width * 3) / 4
            let marginY = (scrollView.bounds.height - height * 2) / 3
            button.tag = index
            button.clsName = buttonsInfo[index]["clsName"]
            var index = index
            index = (index >= 6) ? (index - 6) : index
            let x = marginX + (marginX + width) * CGFloat(index % 3)
            let y = marginY + (marginY + height) * CGFloat(index / 3)
            button.frame = CGRect(x: x, y: y, width: width, height: height)
            parentView.addSubview(button)
            button.addTarget(self, action: #selector(clickFunctionButton), for: UIControl.Event.touchUpInside)
        }
    }
}

// MARK: - animation methods
private extension SCComposeTypeView{
    
    /// hide buttons with animation when shut down the compose view
   func hideButtons(){
        let currentSubView = getCurrentSubView()
        for (index,button) in currentSubView.subviews.enumerated().reversed(){
            let anim : POPSpringAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            anim.fromValue = button.center.y
            anim.toValue = button.center.y + 320
            anim.beginTime = CACurrentMediaTime() + CFTimeInterval(currentSubView.subviews.count - index) * 0.025
            anim.springBounciness = 8
            anim.springSpeed = 8
            button.layer.pop_add(anim, forKey: nil)
            if index == 0{
                anim.completionBlock = { (_,_)->()in
                     self.hideCurrentView()
                }
            }
        }
    }
    func hideCurrentView(){
        let anim: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim.fromValue = 1
        anim.toValue = 0
        anim.duration = 0.25
        pop_add(anim, forKey: nil)
        anim.completionBlock = { (_,_)->()in
            self.removeFromSuperview()
        }
    }
    /// show current view with animation
    func showCurrentView(){
        guard let lv = leftView else {
            return
        }
        let anim : POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim.fromValue = 0
        anim.toValue = 1
        anim.duration = 0.25
        pop_add(anim, forKey: nil)
        for (index,button) in lv.subviews.enumerated(){
            let anim:POPSpringAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            anim.fromValue = button.center.y + 320
            anim.toValue = button.center.y
            anim.springBounciness = 8
            anim.springSpeed = 8
            anim.beginTime = CACurrentMediaTime() + CFTimeInterval(index) * 0.025
            button.layer.pop_add(anim, forKey: nil)
        }
    }
    
    /// get the selected subView in scrollView
    ///
    /// - Returns: left view or right view
    func getCurrentSubView()->UIView{
        let currentSubView : UIView?
        if scrollView.contentOffset.x / scrollView.bounds.width == 0{
            currentSubView = leftView
        } else{
            currentSubView = rightView
        }
        return currentSubView!
    }
}
