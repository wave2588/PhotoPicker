//
//  Calculate.swift
//  PhotoPicker
//
//  Created by wave on 2018/12/1.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

//    假设:
//    任意容器    450*300        1.5
//    任意图片1   800*900        0.888..
//    任意图片2   900*400        2.25
//    容器比      float scale =450/300;        1.5
//    图片比例    float imgscale=800/900        0.888
//
//    200*300  0.66
//
//    100*600 1666
//    if(scale>imgscale)  缩略的时候按照容器的高进行缩略 适合图片1
//    {
//        图片缩放比例应该是   从 高900 缩放到容器的300 等于说缩放了  三倍
//        那么图片的宽度应该是 800/3= 图片的宽度
//    }
//    else (scale<imgscale) 缩放的时候按照容器的宽进行缩略  适合图片2
//    {
//        图片缩放比例应该是   从 宽900 缩放到容器的450 等于说缩放了  2倍
//        那么图片的高度 应该是 400/2=200
//    }

//    /// 切换任意比例...
//    func getImageSize(containerSize: CGSize, image: UIImage) -> CGSize {
//
//        let imageW = image.size.width
//        let imageH = image.size.height
//
//        var newW: CGFloat = containerSize.width
//        var newH: CGFloat = containerSize.height
//
//        if imageW <= containerSize.width && imageH <= containerSize.height {
//        } else {
//            if imageW / imageH < containerSize.width / containerSize.height {
//                newW = containerSize.width
//                newH = imageH / (imageW / containerSize.width)
//            } else {
//                newW = imageW / (imageH / containerSize.height)
//                newH = containerSize.height
//            }
//        }
//        return CGSize(width: newW, height: newH)
//    }
//
//    /// 还原
//    func getOriginalImageSize(image: UIImage) -> CGSize {
//
//        let imageW = image.size.width
//        let imageH = image.size.height
//
//        var newW: CGFloat = 0
//        var newH: CGFloat = 0
//
//            let kWidth = UIScreen.main.bounds.width
//            let kHeight = kWidth
//        if imageW / imageH < 1 {
//            newW = kWidth
//            newH = imageH / (imageW / kWidth)
//        } else {
//            newW = imageW / (imageH / kHeight)
//            newH = kHeight
//        }
//
//        return CGSize(width: newW, height: newH)
//    }

let SCALE: CGFloat = 3 / 4

/// 切换任意比例...
func getImageSize(containerW: CGFloat, containerH: CGFloat, image: UIImage) -> CGSize {
    
    let imageW = image.size.width
    let imageH = image.size.height
    
    var newW: CGFloat = containerW
    var newH: CGFloat = containerH
    
    if imageW / imageH < containerW / containerH {
        newW = containerW
        newH = imageH / (imageW / containerW)
    } else {
        newW = imageW / (imageH / containerH)
        newH = containerH
    }
    return CGSize(width: newW, height: newH)
}

/// 留白
func getRemainRect(image: UIImage) -> CGRect {
    
    let imageW = image.size.width
    let imageH = image.size.height
    
    let width = UIScreen.main.bounds.width
    let height = width
    
    if imageW > imageH {
        let containerH = height * SCALE
        let containerW = width
        let size = getImageSize(containerW: containerW, containerH: containerH, image: image)
        return CGRect(x: 0, y: (height - size.height) * 0.5, width: size.width, height: size.height)
    } else {
        let containerW = width * SCALE
        let containerH = height
        let size = getImageSize(containerW: containerW, containerH: containerH, image: image)
        return CGRect(x: (width - size.width) * 0.5, y: 0, width: size.width, height: size.height)
    }
}

/// 充满
func getFillRect(image: UIImage) -> CGRect {
    let width = UIScreen.main.bounds.width
    let height = width
    let size = getImageSize(containerW: width, containerH: height, image: image)
    return CGRect(x: 0, y: 0, width: size.width, height: size.height)
}

/// 计算 ScrollView Frame
func getScrollViewFrame(scale: Scale) -> CGRect {
    
    let width = UIScreen.main.bounds.width
    let height = width
    
    var x: CGFloat = 0
    var y: CGFloat = 0
    var w: CGFloat = width
    var h: CGFloat = height
    if scale == .oneToOne {
    } else if scale == .fourToThreeHorizontal {
        let newScrollViewH = height * SCALE
        let space = (height - newScrollViewH) * 0.5
        y = space
        h = height - space * 2
    } else if scale == .fourToThreeVertical {
        let newScrollViewW = width * SCALE
        let space = (width - newScrollViewW) * 0.5
        x = space
        w = width - space * 2
    }
    return CGRect(x: x, y: y, width: w, height: h)
}
