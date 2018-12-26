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
    let w = width * wScale
    let h = height * wScale
    let rect = CGRect(x: x, y: y, width: w, height: h)
    
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
    
    /// 如果是留白的情况, 单独处理  (ps: 留白的图片暂时用)
    if scale == .oneToOne && editInfo.mode == .remain {
        let view = ScreenshotView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
        editInfo.image = view.setEditInfoImage(firstScale: scale, item: tItem).editInfo?.image
        tItem.editInfo = editInfo
        return tItem
        
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
    let w = width * wScale
    let h = height * wScale
    let rect = CGRect(x: x, y: y, width: w, height: h)
    
    let img = image.cropImage(rect: rect)
    editInfo.image = img

    tItem.editInfo = editInfo
    
    return tItem
}

//func remain(item: AssetItem) -> AssetItem {
//    var tItem = item
//    guard let editInfo = tItem.editInfo,
//          let image = tItem.fullResolutionImage else { return tItem }
//
//
//    let imgW = image.size.width
//    let imgH = image.size.height
//
//    if imgW > imgH {
//        debugPrint("上下留白")
//    } else {
//        debugPrint("左右留白")
//
//        let wh = getContainerSize(Scale.fourToThreeVertical)
//        let width = wh.width
//        let height = wh.height
//        /// 获取容器当前的大小
//        let containerSize = getImageSize(containerW: width * zoomScale, containerH: height * zoomScale, image: image)
//
//    }
    
    

//    return tItem

//    if scale == .oneToOne && editInfo.mode == .remain {
//                let view = ScreenshotView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
//                editInfo.image = view.setEditInfoImage(firstScale: scale, item: tItem).editInfo?.image
//
//        let imgW = img?.size.width ?? 0
//        let imgH = img?.size.height ?? 0
//        if imgW > imgH {
//            debugPrint("上下留白")
//        } else {
//
//            /// 计算留白间隙
//            /// 获取正常的 remain frame
//            let remainFrame = getRemainRect(image: image)
//            let spaceScale = remainFrame.origin.x / UIScreen.main.bounds.width
//
//            debugPrint("remainFrame-->: ", remainFrame, spaceScale)
//
//
//            let imgViewW = imgW - (imgH - imgW)
//            let view = UIView(frame: CGRect(x: 0, y: 0, width: imgW, height: imgW))
//            view.backgroundColor = UIColor.red
//            let imageView = UIImageView(frame: CGRect(x: (imgH - imgW) * 0.5, y: 0, width: imgViewW, height: imgH))
//            imageView.backgroundColor = UIColor.blue
//            view.addSubview(imageView)
//            editInfo.image = view.capture()
//            debugPrint("左右留白")
//            //            debugPrint(view.frame)
//            //            debugPrint(imageView.frame)
//        }
//    }
//}


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
