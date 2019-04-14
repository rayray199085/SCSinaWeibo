//
//  SCRefreshControl.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 30/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit
private let SCRefreshOffset: CGFloat = 126

/// three states of control
///
/// - Normal: below SCRefreshOffset do nothing
/// - Pulling: over SCRefreshOffset but not loosing
/// - WillRefresh: over SCRefreshOffset and loosing
enum SCRefreshState{
    case Normal
    case Pulling
    case WillRefresh
}
/// override refreshControl
class SCRefreshControl: UIControl {
    private weak var scrollView: UIScrollView?
    private lazy var refreshView: SCRefreshView = SCRefreshView.refreshView()
    init(){
        super.init(frame: CGRect())
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    /// add observer
    ///
    /// - Parameter newSuperview: control's superView
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard let sv = newSuperview as? UIScrollView else {
            return
        }
        scrollView = sv
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: [], context: nil)
    }
    
    /// remove observer
    override func removeFromSuperview() {
        superview?.removeObserver(self, forKeyPath: "contentOffset")
        super.removeFromSuperview()
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let sv = scrollView else {
            return
        }
        let height = -(sv.contentInset.top + sv.contentOffset.y)
        
        if height < 0{
            return
        }
        frame = CGRect(x: 0, y: -height, width: sv.bounds.width, height: height)
        refreshView.refreshState != SCRefreshState.WillRefresh ? refreshView.parenViewtHeight = height : ()
        if sv.isDragging {
            if height > SCRefreshOffset && (refreshView.refreshState == SCRefreshState.Normal){
                    refreshView.refreshState = SCRefreshState.Pulling
            }else if height <= SCRefreshOffset && (refreshView.refreshState == SCRefreshState.Pulling){
                    refreshView.refreshState = SCRefreshState.Normal
            }
        }else{
            if refreshView.refreshState == SCRefreshState.Pulling{
                beginRefreshing()
                sendActions(for: UIControl.Event.valueChanged)
            }
        }
    }
    func beginRefreshing(){
        guard let sv = scrollView else{
            return
        }
        if refreshView.refreshState == SCRefreshState.WillRefresh{
            return
        }
        refreshView.refreshState = SCRefreshState.WillRefresh
        
        var inset = sv.contentInset
        inset.top += SCRefreshOffset
        sv.contentInset = inset
        refreshView.parenViewtHeight = SCRefreshOffset
    }
    
    func endRefreshing(){
        guard let sv = scrollView else{
            return
        }
        if refreshView.refreshState != SCRefreshState.WillRefresh{
            return
        }
        
        var inset = sv.contentInset
        inset.top -= SCRefreshOffset
        sv.contentInset = inset
        refreshView.refreshState = SCRefreshState.Normal
    }
}

// MARK: - setup UI and constraints
extension SCRefreshControl{
    private func setupUI(){
        backgroundColor = superview?.backgroundColor

        addSubview(refreshView)
        refreshView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: refreshView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0))

        addConstraint(NSLayoutConstraint(item: refreshView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0))

         addConstraint(NSLayoutConstraint(item: refreshView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: refreshView.bounds.width))
         addConstraint(NSLayoutConstraint(item: refreshView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: refreshView.bounds.height))
    }
}

