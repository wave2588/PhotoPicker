//
//  PhotoPickerManager.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/20.
//  Copyright © 2018 wave. All rights reserved.
//

import Foundation

public enum MessageType {
    case normal
    case success
    case fail
}

public class PhotoPickerConfigManager {
    
    public static let shared = PhotoPickerConfigManager()
    
    /// 失败 or 成功的提示回调
    public var message: ((MessageType, String)->())?

    /// 统计
    public var statistics: ((String, TimeInterval?) -> ())?
    
    /// 调试时候使用, 不用开启...
    public var isDebug = false
}

/*
 PO-IMPRESSION-00, [*]展示了图库照片, 0
 PO-EVENT-01, [*]展示了选择预览的图片, 0
 PO-ACTION-02, [*]点击选中了图库中的图片, 0
 PO-ACTION-03, [*]点击切换画面比例按钮, 0
 PO-ACTION-04, [*]手动缩放和调整了画布中的图片, 0
 PO-ACTION-05, [*]点击切换画布留白按钮, 0
 PO-ACTION-06, [*]点击切换画布充满按钮, 0
 PO-ACTION-07, [*]点击切换了图库, 0
 PO-ACTION-08, [*]安装控制阀上划展开了图库列表, 0
 PO-ACTION-09, [*]安装控制阀下划收起了图库列表, 0
 PO-ACTION-10, [*]点击了图库选择界面的关闭按钮, 0
 PO-ACTION-11, [*]点击了图库选择界面的下一步, 0
 PO-INTERVAL-12, 图库选择界面停留时长, 0
 */
