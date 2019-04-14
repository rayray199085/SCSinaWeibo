//
//  SCEmoticonFlowLayout.swift
//  EmoticonKeyboard
//
//  Created by Stephen Cao on 7/4/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit

class SCEmoticonFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else {
            return
        }
        itemSize = collectionView.bounds.size
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        collectionView.bounces = false
        collectionView.isPagingEnabled = true
        scrollDirection = UICollectionView.ScrollDirection.horizontal        
    }
}
