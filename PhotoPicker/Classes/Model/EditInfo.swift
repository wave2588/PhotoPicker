//
//  sssssss.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/15.
//  Copyright © 2018 wave. All rights reserved.
//

import Foundation
import UIKit

public enum Scale {
    case oneToOne
    case fourToThreeHorizontal
    case fourToThreeVertical
}

enum Mode {
    case fill
    case remain
}

public struct EditInfo {
    
    var image: UIImage?
    
    /// 通过 zoomScale   contentOffset 可以复原编辑过后的状态
    var zoomScale: CGFloat
    var contentOffset: CGPoint
    var scale: Scale

    /// 填充模式
    var mode: Mode

    init(zoomScale: CGFloat, contentOffset: CGPoint, scale: Scale, mode: Mode) {
        self.zoomScale = zoomScale
        self.contentOffset = contentOffset
        self.scale = scale
        self.mode = mode
    }
    
}
