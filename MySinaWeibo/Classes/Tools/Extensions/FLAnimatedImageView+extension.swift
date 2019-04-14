//
//  FLAnimatedImage+extension.swift
//  TestFLAnimatedImage
//
//  Created by Stephen Cao on 12/4/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import Foundation
import FLAnimatedImage
import SDWebImage

extension FLAnimatedImageView {
    func setGifImage(with url: URL?, placeholderImage: UIImage?) {
        sd_internalSetImage(with: url, placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), operationKey: nil, setImageBlock: { [weak self] (image, imageData) in
            guard let strongSelf = self else { return }
            
            let imageFormat = NSData.sd_imageFormat(forImageData: imageData)
            if imageFormat == .GIF {
                // Enter global queue
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    // Create FLAnimatedImage in global queue
                    let animatedImage = FLAnimatedImage(animatedGIFData: imageData)
                
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        // Set image in main queue
                        strongSelf.animatedImage = animatedImage
                        strongSelf.image = nil
                    }
                }
            } else {
                // Set image in main queue
                strongSelf.image = image
                strongSelf.animatedImage = nil
            }
            }, progress: nil, completed: nil)
    }
}
