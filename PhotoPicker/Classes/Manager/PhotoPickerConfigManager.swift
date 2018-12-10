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
    
    /// 设置最多选择数, 在 present 之前设置
    public var maxSelectCount = 9
    
    /// 比例尺
    public var scale: Scale?
    
    /// 调试时候使用, 不用开启...
    public var isDebug = false
}
