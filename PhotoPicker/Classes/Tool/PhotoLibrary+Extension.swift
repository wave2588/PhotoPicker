//
//  PhotoLibrary+Extension.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/12.
//  Copyright © 2018 wave. All rights reserved.
//

import Foundation
import Photos

extension PhotoLibrary {
    
    func titleOfAlbumForChinse(title:String) -> String {
        
        let dict = [
            "Slo-mo"            : "慢动作",
            "Recently Added"    : "最近添加",
            "Favorites"         : "个人收藏",
            "Recently Deleted"  : "最近删除",
            "Videos"            : "视频",
            "All Photos"        : "所有照片",
            "Selfies"           : "自拍",
            "Screenshots"       : "屏幕快照",
            "Camera Roll"       : "相机胶卷",
            "Portrait"          : "人像"
        ]
        
        if let cn = dict[title] {
            return cn
        }
        return title
    }
}

extension PhotoLibrary {
    
    static func timeFormatted(timeInterval: TimeInterval) -> String {
        let seconds: Int = lround(timeInterval)
        var hour: Int = 0
        var minute: Int = Int(seconds/60)
        let second: Int = seconds % 60
        if minute > 59 {
            hour = minute / 60
            minute = minute % 60
            return String(format: "%d:%d:%02d", hour, minute, second)
        } else {
            return String(format: "%d:%02d", minute, second)
        }
    }
}


/// 以下是类方法, 直接调用
extension PhotoLibrary {
    
    static func fullResolutionImageData(asset: PHAsset) -> UIImage? {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.resizeMode = .none
        options.isNetworkAccessAllowed = false
        options.version = .current
        var image: UIImage? = nil
        //        let manager = PHImageManager.default()
        PHCachingImageManager().requestImageData(for: asset, options: options) { (imageData, dataUIT, orientation, info) in
            if let data = imageData {
                image = UIImage(data: data)
            }
        }
        return image
    }
    
    static func imageAsset(asset: PHAsset, size: CGSize, options: PHImageRequestOptions?, completionBlock:@escaping (UIImage,Bool)-> Void) -> PHImageRequestID {
        var options = options
        if options == nil {
            options = PHImageRequestOptions()
            options?.isSynchronous = false
            options?.resizeMode = .exact
            options?.deliveryMode = .opportunistic
            options?.isNetworkAccessAllowed = true
        }
        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: size.width*scale, height: size.height*scale)
        let requestId = PHCachingImageManager().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, info in
            let complete = (info?["PHImageResultIsDegradedKey"] as? Bool) == false
            if let image = image {
                completionBlock(image,complete)
            }
        }
        
        return requestId
    }

}
