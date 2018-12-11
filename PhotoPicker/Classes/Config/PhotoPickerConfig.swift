//
//  PhotoPickerConfig.swift
//  PhotoPicker
//
//  Created by wave on 2018/12/11.
//  Copyright © 2018 wave. All rights reserved.
//

import Foundation

public class PhotoPickerConfig: NSObject {
    
    /// 设置最多选择数
    public var maxSelectCount = 9
    
    /// 比例尺
    public var scale: Scale = .oneToOne
}
