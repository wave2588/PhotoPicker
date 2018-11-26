//
//  ScreenshotTool.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/20.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

class ScreenshotTool {
    
    static func getImages(assetItems: [AssetItem]) -> (Scale,[UIImage]) {
        
        guard let firstItem = assetItems.first,
              let firstItemEditInfo = firstItem.editInfo  else {
            return (Scale.oneToOne, [UIImage]())
        }

        var images = [UIImage]()
        assetItems.forEach { item in
            let view = ScreenshotView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
            if let image = view.setEditInfoImage(firstEditInfo: firstItemEditInfo, item: item).editInfo?.image {
                images.append(image)
            }
        }
        
        return (firstItemEditInfo.scale, images)
    }
}
