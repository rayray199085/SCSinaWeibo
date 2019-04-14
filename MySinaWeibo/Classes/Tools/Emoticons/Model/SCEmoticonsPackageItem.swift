//
//  SCEmoticonsPackageItem.swift
//  TestMixWordsAndImage
//
//  Created by Stephen Cao on 3/4/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit

class SCEmoticonsPackageItem: NSObject {
    @objc var emoticon_group_name: String?
    @objc var bgImageName : String?
    @objc var emoticon_group_path: String?{
        didSet{
            guard let fileName = emoticon_group_path,
                  let path = Bundle.main.path(forResource: "Emoticons.bundle", ofType: nil),
                  let bundle = Bundle(path: path),
                  let emoPath = bundle.path(forResource: fileName, ofType: ".plist", inDirectory: fileName),
                  let emoticonsDict = NSDictionary(contentsOfFile: emoPath),
                  let emoticonsArray = emoticonsDict["emoticon_group_emoticons"],
                  let subModels = NSArray.yy_modelArray(with: SCEmoticonsItem.self, json: emoticonsArray) as? [SCEmoticonsItem] else {
                return
            }
            emoticonsItems += subModels
            for item in emoticonsItems{
                item.directory = fileName
            }
        }
    }
    lazy var emoticonsItems = [SCEmoticonsItem]()
    var pageCount :Int {
        return (emoticonsItems.count - 1)/20 + 1
    }
    func getEmoticonsItems(page : Int)->[SCEmoticonsItem]{
        let startingIndex = page * 20
        let sectionLength = emoticonsItems.count
        let remain = sectionLength - startingIndex >= 20 ? 20 : sectionLength - startingIndex
        let range = NSRange(location: startingIndex, length: remain)
        let subArray = (emoticonsItems as NSArray).subarray(with: range) as! [SCEmoticonsItem]
        return subArray
    }
    override var description: String{
        return yy_modelDescription()
    }
}
