//
//  Alu.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/12.
//  Copyright © 2018 wave. All rights reserved.
//

import Foundation
import Photos

public struct AlbumItem {
    
    /// 最终选中的
    var selectedAssetItems: [AssetItem] {
        get {
            return assetItems.filter({ item -> Bool in
                return item.selectedIndex != 0
            })
        }
    }
    
    /// 当前这个相册是否可以选中视频 (如果选中了照片, 则不能再选中视频, 点击视频后直接跳转了)
    var isSelectVideo = true

    /// 相册 id, 缓存时用
    var id: String

    /// 相簿名称
    var title: String

    var assetItems: [AssetItem]
    
    init(id: String, title: String, assetItems: [AssetItem]) {
        self.id = id
        self.title = title
        self.assetItems = assetItems
    }
}
