//
//  PhotoPickerManager.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/20.
//  Copyright © 2018 wave. All rights reserved.
//

import Foundation

public class PhotoPickerConfigManager {
    
    public static let shared = PhotoPickerConfigManager()
    
    public var fail: ((String)->())?
    
    /// 调试时候使用, 不用开启...
    public var isDebug = false
}
