//
//  FeedbackFunction.swift
//  iOS
//
//  Created by Gesen on 2018/11/5.
//  Copyright © 2018 Zhihu. All rights reserved.
//

import UIKit

/// 碰撞反馈
///
/// - Parameter style: 反馈类型
func impactFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
    if Runtime.isiPhoneX {
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator(style: style).impactOccurred()
        }
    }
}

