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
    
    static let safeTop: CGFloat = {
        var safeTop: CGFloat = 0
        if #available(iOS 11.0, *) {
            safeTop = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
        }
        return safeTop
    }()
    
    static let isiPhoneX: Bool = {
        let window = UIApplication.shared.keyWindow
        if #available(iOS 11.0, *) {
            if window?.safeAreaInsets.bottom ?? 0 > 0.0.cgFloat {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }()
}
