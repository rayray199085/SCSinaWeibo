//
//  SCvisitorView.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 22/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit
/// visitor view
class SCvisitorView: UIView {
    // register button
    lazy var registrationButton = UIButton.textButton(withTitle: "Sign Up", andWithFontSize: 20, andWithNormalColor: UIColor.orange, andWithHighlight: UIColor.black, andWithBackgroundImageName: "common_button_white_disable")
    // login button
    lazy var loginButton = UIButton.textButton(withTitle: "Log In", andWithFontSize: 20, andWithNormalColor: UIColor.darkGray, andWithHighlight: UIColor.black, andWithBackgroundImageName: "common_button_white_disable")
    
     /// use dictionary to setup visitor view, home page imageName is empty
    var visitorInfo : [String:String]?{
        didSet{
            guard let imageName = visitorInfo?["imageName"],
                let message = visitorInfo?["message"] else {
                    return
            }
            tipsLabel.text = message
            if imageName == ""{
                startWheelRotation()
                return
            }
            iconView.image = UIImage(named: imageName)
            secondIconView.isHidden = true
            maskIconView.isHidden = true
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// start wheel animation
    private func startWheelRotation(){
        let anim = CABasicAnimation.doRotateAnim(withRepeatCount: CGFloat(MAXFLOAT), andWithDuration: 15, andWithShouldRemoveOnCompletion: false)
        iconView.layer.add(anim, forKey: nil)
    }
   
    // wheel
    private lazy var iconView = UIImageView(fitImageName: "visitordiscover_feed_image_smallicon");
    // mask
    private lazy var maskIconView = UIImageView(fitImageName: "visitordiscover_feed_mask_smallicon")
    // house
    private lazy var secondIconView = UIImageView(image: UIImage(named: "visitordiscover_feed_image_house"))
    // tips
    private lazy var tipsLabel = UILabel(text: "It's free and always will be.", andWithFontSize: 14, andColor: UIColor.darkGray);
}
/// set up UI
extension SCvisitorView{
    func setupUI(){
        backgroundColor = UIColor(hexValue: 0xEDEDED)
         // add subViews
        addSubview(iconView)
        addSubview(maskIconView)
        addSubview(secondIconView)
        addSubview(tipsLabel)
        addSubview(registrationButton)
        addSubview(loginButton)
        for childView in subviews{
            childView.translatesAutoresizingMaskIntoConstraints = false
        }
        let margin = CGFloat(20)
        // add first icon constraint
        addConstraint(NSLayoutConstraint(item: iconView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: iconView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: -60))
         // add second icon constraint
        addConstraint(NSLayoutConstraint(item: secondIconView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: iconView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0))
         addConstraint(NSLayoutConstraint(item: secondIconView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: iconView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: 0))
        // add label
        addConstraint(NSLayoutConstraint(item: tipsLabel, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: iconView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: tipsLabel, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: iconView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: margin))
        // add register button
        addConstraint(NSLayoutConstraint(item: registrationButton, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: -30))
        addConstraint(NSLayoutConstraint(item: registrationButton, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: tipsLabel, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: margin))
        addConstraint(NSLayoutConstraint(item: registrationButton, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: 100))
        // add login button
        addConstraint(NSLayoutConstraint(item: loginButton, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 30))
        addConstraint(NSLayoutConstraint(item: loginButton, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: tipsLabel, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: margin))
        addConstraint(NSLayoutConstraint(item: loginButton, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: registrationButton, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1.0, constant: 0))
        // add mask icon constraint
        addConstraint(NSLayoutConstraint(item: maskIconView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: maskIconView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: maskIconView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: loginButton, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: 0))
    }
}
