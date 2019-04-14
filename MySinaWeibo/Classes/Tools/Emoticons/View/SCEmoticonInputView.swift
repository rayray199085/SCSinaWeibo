//
//  SCEmoticonInputView.swift
//  EmoticonKeyboard
//
//  Created by Stephen Cao on 7/4/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit
private let reuseIdentifier = "emoji_cell"
class SCEmoticonInputView: UIView {
    @IBOutlet weak var pageIndicator: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    private var selectedEmoticonCallBack: ((_ item:SCEmoticonsItem?)->())?
    @IBOutlet weak var toolbar: SCEmoticonToolbar!
    class func inputView(selectedEmoticon: @escaping (_ item:SCEmoticonsItem?)->())->SCEmoticonInputView{
        let nib = UINib(nibName: "SCEmoticonInputView", bundle: nil)
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! SCEmoticonInputView
        v.collectionView.delegate = v
        v.collectionView.dataSource = v
        v.selectedEmoticonCallBack = selectedEmoticon
        return v
    }
    override func awakeFromNib() {
        collectionView.register(SCEmoticonCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = UIColor.white
        toolbar.delegate = self
        let normalIndicatorImage = UIImage(named: "compose_keyboard_dot_normal")
        let selectedIndicatorImage = UIImage(named: "compose_keyboard_dot_selected")
        pageIndicator.customIndicatorImages(normalImage: normalIndicatorImage, selectedImage: selectedIndicatorImage)
    }
}
extension SCEmoticonInputView: UICollectionViewDataSource, UICollectionViewDelegate{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return SCEmoticonsManager.sharedManager.emoticonsPackages.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SCEmoticonsManager.sharedManager.emoticonsPackages[section].pageCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SCEmoticonCollectionViewCell
        cell.emoticonsGroup = SCEmoticonsManager.sharedManager.emoticonsPackages[indexPath.section].getEmoticonsItems(page: indexPath.item)
        cell.delegate = self
        return cell
    }
}
extension SCEmoticonInputView: SCEmoticonCollectionViewCellDelegate{
    
    /// select emoticonsitem callback
    ///
    /// - Parameters:
    ///   - cell: selected page
    ///   - item: selected item
    func selectedEmoticonItem(cell: SCEmoticonCollectionViewCell, item: SCEmoticonsItem?) {
        selectedEmoticonCallBack?(item)
        guard let item = item else{
            return
        }
        let recentUsedEmoticonIndexPath = IndexPath(item: 0, section: 0)
        if cell != collectionView.cellForItem(at: recentUsedEmoticonIndexPath){
            SCEmoticonsManager.sharedManager.updateRecentEmoticons(emoticonsItem: item)
            collectionView.reloadItems(at: [recentUsedEmoticonIndexPath])
        }
    }
}

// MARK: - SCEmoticonToolbarDelegate function
extension SCEmoticonInputView: SCEmoticonToolbarDelegate{
    func didSelectSection(toolBar: SCEmoticonToolbar, sectionId: Int) {
        pageIndicator.currentPage = sectionId
        collectionView.selectItem(at: IndexPath(item: 0, section: sectionId), animated: false, scrollPosition: UICollectionView.ScrollPosition.left)
        pageIndicator.numberOfPages = collectionView.numberOfItems(inSection: sectionId)
        pageIndicator.currentPage = 0
    }
}

// MARK: - scrollView delegate function
extension SCEmoticonInputView{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var center = scrollView.center
        center.x += scrollView.contentOffset.x
        
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        var targetIndexPath: IndexPath?
        for indexPath in visibleIndexPaths{
             let cell = collectionView.cellForItem(at: indexPath)
            if cell?.frame.contains(center) == true{
                targetIndexPath = indexPath
                break
            }
        }
        guard let indexPath = targetIndexPath else{
            return
        }
        toolbar.selectedButtonTag = indexPath.section
        pageIndicator.numberOfPages = collectionView.numberOfItems(inSection: indexPath.section)
        pageIndicator.currentPage = indexPath.item
    }
}
