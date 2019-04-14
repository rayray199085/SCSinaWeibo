//
//  SCEmoticonToolbar.swift
//  EmoticonKeyboard
//
//  Created by Stephen Cao on 7/4/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit
@objc protocol SCEmoticonToolbarDelegate: NSObjectProtocol{
    @objc optional func didSelectSection(toolBar:SCEmoticonToolbar, sectionId:Int)
}
class SCEmoticonToolbar: UIView {
    weak var delegate: SCEmoticonToolbarDelegate?
    var selectedButtonTag: Int = 0{
        didSet{
            setAllButtonsNotSelected()
            let btn = subviews[selectedButtonTag] as! UIButton
            btn.isSelected = true
        }
    }
    override func awakeFromNib() {
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let buttonCount = CGFloat(subviews.count)
        let height = bounds.height
        let width = bounds.width  / buttonCount
        for (index, btn) in subviews.enumerated(){
            btn.frame = CGRect(x: width * CGFloat(index), y: 0, width: width, height: height)
        }
    }
    @objc private func clickToolbarButton(sender: UIButton){
        selectedButtonTag = sender.tag
        delegate?.didSelectSection?(toolBar: self, sectionId: sender.tag)
    }
    
    private func setAllButtonsNotSelected(){
        for btn in subviews as! [UIButton]{
            btn.isSelected = false
        }
    }
}
private extension SCEmoticonToolbar{
    func setupUI() {
        let manager = SCEmoticonsManager.sharedManager
        for (index,package) in manager.emoticonsPackages.enumerated(){
            let toolbarButton = UIButton()
            toolbarButton.setTitle(package.emoticon_group_name ?? "", for: [])
            toolbarButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            toolbarButton.setTitleColor(UIColor.white, for: [])
            toolbarButton.setTitleColor(UIColor.darkGray, for: UIControl.State.highlighted)
            toolbarButton.setTitleColor(UIColor.darkGray, for: UIControl.State.selected)
            if let imagePosition = package.bgImageName{
                let normalImageName = "compose_emotion_table_\(imagePosition)_normal"
                let selectedImageName = "compose_emotion_table_\(imagePosition)_selected"
                toolbarButton.setBackgroundImage(UIImage(named: normalImageName), for: [])
                toolbarButton.setBackgroundImage(UIImage(named: selectedImageName), for: .highlighted)
                toolbarButton.setBackgroundImage(UIImage(named: selectedImageName), for: .selected)
            }
            toolbarButton.sizeToFit()
            toolbarButton.tag = index
            toolbarButton.addTarget(self, action: #selector(clickToolbarButton), for: [UIControl.Event.touchUpInside])
            toolbarButton.isSelected = index == 0 ? true : false
            addSubview(toolbarButton)
        }
    }
}
