//
//  ResizeTool.swift
//  PhotoPicker
//
//  Created by wave on 2018/12/26.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit
import SwifterSwift

func croppedFirst(scale: Scale, assetItem: AssetItem) -> AssetItem {

    let wh = getContainerSize(scale)
    let width = wh.width
    let height = wh.height

    var tItem = assetItem
    var editInfo = tItem.editInfo ?? EditInfo(zoomScale: 1, contentOffset: CGPoint(x: 0, y: 0), scale: scale, mode: .fill)

    /// 相册原图
    guard let image = assetItem.fullResolutionImage else {
        debugPrint("获取图片失败")
        return tItem
    }

    let zoomScale = editInfo.zoomScale

    /// 获取容器当前的大小
    let containerSize = getImageSize(containerW: width * zoomScale, containerH: height * zoomScale, image: image)

    let wScale = image.size.width / containerSize.width

    let x = editInfo.contentOffset.x * wScale
    let y = editInfo.contentOffset.y * wScale
    let w = (width * wScale).int
    let h = (height * wScale).int
    let rect = CGRect(x: x, y: y, width: w.cgFloat, height: h.cgFloat)
    let img = image.cropImage(rect: rect)
    editInfo.image = img

    tItem.editInfo = editInfo
    
    return tItem
}

func croppedOther(scale: Scale, assetItem: AssetItem) -> AssetItem {
    
    let wh = getContainerSize(scale)
    let width = wh.width
    let height = wh.height

    var tItem = assetItem
    var editInfo = tItem.editInfo ?? EditInfo(zoomScale: 1, contentOffset: CGPoint(x: 0, y: 0), scale: scale, mode: .fill)
    
    /// 如果是留白的情况, 单独处理
    if scale == .oneToOne && editInfo.mode == .remain {
        
        let view = ScreenshotView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
        editInfo.image = view.setEditInfoImage(firstScale: scale, item: tItem).editInfo?.image
        tItem.editInfo = editInfo
        return tItem

//        /// 如果选择了留白, 并且还放大了图片, 则先用老办法处理
//        if editInfo.zoomScale != 1 {
//            let view = ScreenshotView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
//            editInfo.image = view.setEditInfoImage(firstScale: scale, item: tItem).editInfo?.image
//            tItem.editInfo = editInfo
//            return tItem
//        }
//
//        tItem.editInfo = editInfo
//        return remain(item: tItem)
    }

    /// 相册原图
    guard let image = assetItem.fullResolutionImage else {
        debugPrint("获取图片失败")
        return tItem
    }
    
    let zoomScale = editInfo.zoomScale
    
    /// 获取容器当前的大小
    let containerSize = getImageSize(containerW: width * zoomScale, containerH: height * zoomScale, image: image)
    
    let wScale = image.size.width / containerSize.width
    
    let x = editInfo.contentOffset.x * wScale
    let y = editInfo.contentOffset.y * wScale
    let w = (width * wScale).int
    let h = (height * wScale).int
    let rect = CGRect(x: x, y: y, width: w.cgFloat, height: h.cgFloat)

    let img = image.cropImage(rect: rect)
    editInfo.image = img

    tItem.editInfo = editInfo
    
    return tItem
}

func remain(item: AssetItem) -> AssetItem {
    var tItem = item
    guard let image = tItem.fullResolutionImage else { return tItem }
    var editInfo = tItem.editInfo!

    let imgW = image.size.width
    let imgH = image.size.height
    
    let zoomScale = editInfo.zoomScale
    
    if imgW > imgH {
        let wh = getContainerSize(Scale.fourToThreeHorizontal)
        
        let width = wh.width
        let height = wh.height
        /// 获取容器当前的大小
        let containerSize = getImageSize(containerW: width * zoomScale, containerH: height * zoomScale, image: image)
        /// 计算出顶部留白的比例, 用容器高度 * 比例 即可
        let kHeight = UIScreen.main.bounds.width
        let topSpace = (kHeight - containerSize.height) * 0.5
        let spaceScale = topSpace / kHeight
        /// 先把 view 画出来  如果是特别大的图, 则缩放下containerView
        var containerViewW = imgW
        var containerViewH = imgW
        var imageViewW = imgW
        var imageViewH = imgH
        if image.size.height > 1080 {
            /// 1080
            containerViewW = 1080
            containerViewH = 1080
            imageViewW = containerViewW
            imageViewH = containerViewH - containerViewH * spaceScale * 2
        }
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: containerViewW, height: containerViewH))
        containerView.backgroundColor = .white
        let imageView = UIImageView(frame: CGRect(x: 0, y: containerView.height * spaceScale, width: imageViewW, height: imageViewH))
        imageView.image = image
        containerView.addSubview(imageView)
        editInfo.image = containerView.capture()
    } else {
        let wh = getContainerSize(Scale.fourToThreeVertical)
        let width = wh.width
        let height = wh.height
        /// 获取容器当前的大小
        let containerSize = getImageSize(containerW: width * zoomScale, containerH: height * zoomScale, image: image)
        /// 计算出左边留白的比例, 用容器宽度 * 比例 即可
        let kWidth = UIScreen.main.bounds.width
        let leftSpace = (kWidth - containerSize.width) * 0.5
        let spaceScale = leftSpace / kWidth
        /// 先把 view 画出来  如果是特别大的图, 则缩放下containerView
        var containerViewW = imgH
        var containerViewH = imgH
        var imageViewW = imgW
        var imageViewH = imgH
        if image.size.height > 1080 {
            /// 1080
            containerViewW = 1080
            containerViewH = 1080
            imageViewW = containerViewW - containerViewW * spaceScale * 2
            imageViewH = containerViewH
        }
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: containerViewW, height: containerViewH))
        containerView.backgroundColor = .white
        let imageView = UIImageView(frame: CGRect(x: containerView.width * spaceScale, y: 0, width: imageViewW, height: imageViewH))
        imageView.image = image
        containerView.addSubview(imageView)
        editInfo.image = containerView.capture()
    }
    
    tItem.editInfo = editInfo

    return tItem
}


/// 获取正常比例下容器 size
func getContainerSize(_ scale: Scale) -> CGSize {
    
    var width = UIScreen.main.bounds.width
    var height = width
    switch scale {
    case .oneToOne:
        break
    case .fourToThreeHorizontal:
        height = height * SCALE
        break
    case .fourToThreeVertical:
        width = width * SCALE
        break
    }
    return CGSize(width: width, height: height)
}
