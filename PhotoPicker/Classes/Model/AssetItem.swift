//
//  ssss.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/12.
//  Copyright © 2018 wave. All rights reserved.
//

import Foundation
import Photos

public struct AssetItem {
    
    enum AssetType {
        case photo, video
    }
    var type: AssetType {
        get {
            if phAsset.mediaType == .video {
                return .video
            } else {
                return .photo
            }
        }
    }
    
    var fullResolutionImage: UIImage? {
        get {
            return PhotoLibrary.fullResolutionImageData(asset: phAsset)
        }
    }
    
    /// 获取视频文件 session
    func getVideoFileUrl(completionHandler:@escaping (_ session: AVAssetExportSession?) -> ()) {
        if type == .video {
            let resource = PHAssetResource.assetResources(for: phAsset)
            let isok = resource.first?.value(forKey: "locallyAvailable") as? Bool
            if isok == true {
                PhotoLibrary.video(asset: phAsset, completionHandler: completionHandler)
                return
            }
        }
        completionHandler(nil)
    }

    /// 照片只会是 0
    var duration: String {
        get {
            return PhotoLibrary.timeFormatted(timeInterval: phAsset.duration)
        }
    }
    
    /// 选中的下标 (0 表示未选中)
    var selectedIndex = 0
    /// 是否是当前选中的
    var isCurrentSeleted = false
    
    /// 编辑过后的图片
    var editInfo: EditInfo?
    
    var id: String
    var phAsset: PHAsset
    
    init(id: String, phAsset: PHAsset) {
        self.id = id
        self.phAsset = phAsset
    }

}

