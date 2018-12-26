//
//  ScreenshotTool.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/20.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

class ScreenshotTool {
    
    static func getConfigImages(scale: Scale, assetItems: [AssetItem]) -> (Scale,[UIImage]) {
        var images = [UIImage]()
        for i in 0..<assetItems.count {
            let item = assetItems[i]
//            let view = ScreenshotView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
//            if let image = view.setEditInfoImage(firstScale: scale, item: item).editInfo?.image {
//                images.append(image)
//            }
            if let image = croppedOther(scale: scale, assetItem: item).editInfo?.image {
                images.append(image)
            }
        }
        
        return (scale, images)
    }
    
    static func getImages(scale: Scale, assetItems: [AssetItem]) -> (Scale,[UIImage]) {

        var images = [UIImage]()
        for i in 0..<assetItems.count {
            let item = assetItems[i]
            
            if i == 0 {
                if let image = croppedFirst(scale: scale, assetItem: item).editInfo?.image {
                    images.append(image)
                }
            } else {
                if let image = croppedOther(scale: scale, assetItem: item).editInfo?.image {
                    images.append(image)
                }
            }
        }
        
//        for i in 0..<assetItems.count {
//            let view = ScreenshotView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
//            let item = assetItems[i]
//            debugPrint("原图尺寸--->: ", item.fullResolutionImage?.size)
//            if i == 0 {
//                if let image = view.setFirstEditInfoImage(scale: scale, item: item).editInfo?.image {
//                    images.append(image)
//                    debugPrint("裁剪尺寸--->: ", image.size)
//                }
//            } else {
//                if let image = view.setEditInfoImage(firstScale: scale, item: item).editInfo?.image {
//                    images.append(image)
//                    debugPrint("裁剪尺寸--->: ", image.size)
//                }
//            }
//        }
        
        return (scale, images)
    }
}
