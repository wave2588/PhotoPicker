//
//  Runtime.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/21.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

enum Runtime {
    /// 状态栏高度
    static let statusBarHeight: CGFloat = {
        return UIApplication.shared.statusBarFrame.height
    }()
    
    static let isiPhoneX: Bool = {
        if statusBarHeight == 20 {
            return false
        }
        return true
    }()
}
