//
//  SCEmoticonsManager.swift
//  TestMixWordsAndImage
//
//  Created by Stephen Cao on 3/4/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit
import YYModel

class SCEmoticonsManager{
    let bundle : Bundle = {
        let path = Bundle.main.path(forResource: "Emoticons.bundle", ofType: nil)!
        return Bundle(path: path)!
    }()
    
    static let sharedManager = SCEmoticonsManager()
    lazy var emoticonsPackages = [SCEmoticonsPackageItem]()
    private init(){
       loadPackage()
    }
}

// MARK: - load data
private extension SCEmoticonsManager{
    func loadPackage(){
        guard let plistPath = bundle.path(forResource: "emoticons.plist", ofType: nil),
            let array = NSArray(contentsOfFile: plistPath) as? [[String:String]],
            let models = NSArray.yy_modelArray(with: SCEmoticonsPackageItem.self, json: array) as? [SCEmoticonsPackageItem] else {
            return
        }
        emoticonsPackages += models
    }
}

// MARK: - handle emoji model
extension SCEmoticonsManager{
    
    /// according to the input string return relevant emoji model or nil
    ///
    /// - Parameter string: key string
    /// - Returns: emoji model or nil
    func findEmoticon(keyString : String)->SCEmoticonsItem?{
        for package in emoticonsPackages{
           let result = package.emoticonsItems.filter { (item) -> Bool in
                return item.chs == keyString
            }
            if result.count > 0{
                return result[0]
            }
        }
        return nil
    }
    func getAttributedString(string : String,font : UIFont)->NSAttributedString{
        let pattern = "\\[.*?\\]"
        let attrString = NSMutableAttributedString(string: string)
        guard let regx = try? NSRegularExpression(pattern: pattern, options: []) else {
            return NSAttributedString(string: "")
        }
        let matches = regx.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        for m in matches.reversed(){
            let range = m.range(at: 0)
            let str = (string as NSString).substring(with: range)
            if let item = SCEmoticonsManager.sharedManager.findEmoticon(keyString: str){
                attrString.replaceCharacters(in: range, with: item.imageText(font: font))
            }
        }
        attrString.addAttributes([NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor: UIColor.darkGray], range: NSRange(location: 0, length: attrString.length))
        return attrString
    }
    
    func updateRecentEmoticons(emoticonsItem: SCEmoticonsItem){
        var recentUsedArray = emoticonsPackages[0].emoticonsItems
        // 1. emoticonsItem usedTimes + 1
        emoticonsItem.usedTimes += 1
        // 2. check whether this item has been added to the recent array
        if !recentUsedArray.contains(emoticonsItem){
            recentUsedArray.append(emoticonsItem)
        }
        // 3. sort the array with the order of the highest usage frequency item
        recentUsedArray.sort { (item1, item2) -> Bool in
            return item1.usedTimes > item2.usedTimes
        }
        // 4. if the array size is over 20, delete the item with the least number of usedTimes
        if recentUsedArray.count > 20{
            recentUsedArray.removeLast()
        }
        emoticonsPackages[0].emoticonsItems = recentUsedArray
    }
}
