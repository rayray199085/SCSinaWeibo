//
//  SCEmoticonCollectionViewCell.swift
//  EmoticonKeyboard
//
//  Created by Stephen Cao on 7/4/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit
@objc protocol SCEmoticonCollectionViewCellDelegate: NSObjectProtocol{
    
    /// delegate function
    ///
    /// - Parameter item: select emoji item or nil means select delete button
    @objc optional func selectedEmoticonItem(cell: SCEmoticonCollectionViewCell,item: SCEmoticonsItem?)
}
class SCEmoticonCollectionViewCell: UICollectionViewCell {
    weak var delegate: SCEmoticonCollectionViewCellDelegate?
    private lazy var tipsView: SCEmoticonTipsView  = {
        let tipsView = SCEmoticonTipsView()
        return tipsView
    }()
    private var btnFontSize: CGFloat?{
        didSet{
            tipsView.fontSize = btnFontSize
        }
    }
    var emoticonsGroup : [SCEmoticonsItem]?{
        didSet{
            guard let emoticonsGroup = emoticonsGroup else {
                return
            }
            for v in contentView.subviews{
                v.isHidden = v == contentView.subviews.last ? false : true
            }
            for (index,item) in emoticonsGroup.enumerated(){
                let btn = contentView.subviews[index] as! UIButton
                btn.isHidden = false
                let iconWidth = floor(btn.bounds.width)
                let iconHeight = floor(btn.bounds.height)
                let icon = item.image?.modifyImageSize(size: CGSize(width: iconWidth, height: iconHeight))
                btn.setBackgroundImage(icon, for: [])
                btn.setTitle(item.emojiString, for: [])
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.drawsAsynchronously = true
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func clickEmojiButton(sender : UIButton){
        let index = sender.tag
        var item : SCEmoticonsItem?
        if index < emoticonsGroup!.count{
            item = emoticonsGroup?[index]
        }
        delegate?.selectedEmoticonItem?(cell: self, item: item)
    }
    
    /// long press a button will show tips of the button
    /// long press gesture observer
    /// - Parameter gesture: gesture
    @objc private func longPressGesture(gesture: UILongPressGestureRecognizer){
        let point = gesture.location(in: contentView)
        guard let button = buttonWithLocation(location: point),
            let emoticonsGroup = emoticonsGroup else{
            tipsView.isHidden = true
            tipsView.emoticonsItem = nil
            return
        }
        switch gesture.state {
        case .began, .changed:
            if tipsView.emoticonsItem != nil{
                return 
            }
            tipsView.emoticonsItem = emoticonsGroup[button.tag]
            tipsView.isHidden = false
            // coordinate system update
            let center = convert(button.center, to: window)
            tipsView.center = CGPoint(x: center.x, y: center.y - button.bounds.height / 2)
        case .ended, .cancelled, .failed:
            gesture.state == .ended ? delegate?.selectedEmoticonItem?(cell: self, item: tipsView.emoticonsItem) : ()
            tipsView.isHidden = true
            tipsView.emoticonsItem = nil
        default:
            break
        }
    }
    
    /// add tipsView into newWindow
    ///
    /// - Parameter newWindow:
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        guard let newWindow = newWindow else{
            return
        }
        newWindow.addSubview(tipsView)
        tipsView.isHidden = true
    }
    
    /// pick out selected button when touch in a certain area
    ///
    /// - Parameter location: the location user touch
    /// - Returns: selected button
    private func buttonWithLocation(location : CGPoint)->UIButton?{
        for btn in contentView.subviews{
            if btn == contentView.subviews.last || btn.isHidden{
                return nil
            }
            if btn.frame.contains(location){
                return btn as? UIButton
            }
        }
        return nil
    }
}
private extension SCEmoticonCollectionViewCell{
    func setupUI() {
        let marginX: CGFloat = 10
        let width = (bounds.width - marginX * 8) / 7
        let marginY = (bounds.height - 3 * width) / 4
        let sampleCode = "0x1f603"
        btnFontSize = sampleCode.getEmojiFromHexInt32CodeString()?.getTextFontWithLabelHeight(width: width)
        for index in 0..<21{
            let btn = UIButton(frame: CGRect(x: marginX + (marginX + width) * CGFloat(index % 7), y: marginY + (marginY + width) * CGFloat(index / 7), width: width, height: width))
            if index == 20 {
                let deleteBtnNormalImageName = "compose_emotion_delete"
                btn.setBackgroundImage(UIImage(named: deleteBtnNormalImageName), for: [])
                btn.setBackgroundImage(UIImage(named: "\(deleteBtnNormalImageName)_highlighted"), for: UIControl.State.highlighted)
            }
            btn.titleLabel?.font = UIFont.systemFont(ofSize: btnFontSize ?? 14)
            btn.addTarget(self, action: #selector(clickEmojiButton), for: UIControl.Event.touchUpInside)
            btn.tag = index
            contentView.addSubview(btn)
        }
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture))
        longPress.minimumPressDuration = 0.5
        addGestureRecognizer(longPress)
    }
}
