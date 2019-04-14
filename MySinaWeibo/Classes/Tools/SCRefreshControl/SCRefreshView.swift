//
//  SCRefreshView.swift
//  RefreshComponent
//
//  Created by Stephen Cao on 31/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit

class SCRefreshView: UIView {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView?
    @IBOutlet weak var pullRefreshImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    var parenViewtHeight : CGFloat = 0
    var refreshState:SCRefreshState = SCRefreshState.Normal{
        didSet{
            switch refreshState {
            case SCRefreshState.Normal:
                titleLabel?.text = "Pull harder and Refresh"
                loadingIndicator?.stopAnimating()
                pullRefreshImageView?.isHidden = false
                UIView.animate(withDuration: 0.25) {
                    self.pullRefreshImageView?.transform = CGAffineTransform.identity
                }
              
            case SCRefreshState.Pulling:
                titleLabel?.text = "Release to reload data"
                UIView.animate(withDuration: 0.25) {
                    self.pullRefreshImageView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi - 0.001))
                }
            case SCRefreshState.WillRefresh:
                titleLabel?.text = "Please wait for loading"
                pullRefreshImageView?.isHidden = true
                loadingIndicator?.startAnimating()
            }
        }
    }
    
    class func refreshView()-> SCRefreshView{
        let nib = UINib(nibName: "SCMtRefreshView", bundle: nil)
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! SCRefreshView
        return v
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        
    }
}
