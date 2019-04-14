//
//  SCNewFeatureView.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 27/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit

class SCNewFeatureView: UIView {
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var pageIndicator: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    class func newFeatureView()->SCNewFeatureView{
        let nib = UINib(nibName: "SCNewFeatureView", bundle: nil)
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! SCNewFeatureView
        v.frame = UIScreen.main.bounds
        return v
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        let count = 4
        let imageWidth = UIScreen.main.bounds.width
        let imageHeight = UIScreen.main.bounds.height
        for index in 1...count {
            let imageName = "new_feature_\(index)"
            let iv = UIImageView(image: UIImage(named: imageName))
            iv.frame = CGRect(x: CGFloat(index - 1) * imageWidth, y: 0, width: imageWidth, height: imageHeight)
            scrollView.addSubview(iv)
        }
        scrollView.contentSize = CGSize(width: imageWidth * CGFloat(count + 1), height: 0)
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        enterButton.isHidden = true
        pageIndicator.currentPage = 0
        pageIndicator.isUserInteractionEnabled = false 
    }
    @IBAction func clickEnterButton(_ sender: UIButton) {
        removeFromSuperview()
    }
}

// MARK: - scrollView observer
extension SCNewFeatureView : UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = Int(scrollView.contentOffset.x / UIScreen.main.bounds.width + 0.5)
        enterButton.isHidden = (offset != pageIndicator.numberOfPages - 1) ? true : false
        if offset == pageIndicator.numberOfPages{
            removeFromSuperview()
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
         let offset = Int(scrollView.contentOffset.x / UIScreen.main.bounds.width + 0.5)
         enterButton.isHidden = true
         pageIndicator.currentPage = offset
         pageIndicator.isHidden = (offset > pageIndicator.numberOfPages - 1) ? true : false
    }
}
