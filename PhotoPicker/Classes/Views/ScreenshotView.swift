//
//  ScreenshotView.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/20.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit
import SwifterSwift
import NSObject_Rx

class ScreenshotView: UIView {
    
    /// contentView作用就是用来截图... scrollView截图有坑...
    private let contentView = UIView()
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    
    private let scale: CGFloat = 3 / 4
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ScreenshotView {
    
    func setFirstEditInfoImage(scale: Scale,item: AssetItem) -> AssetItem {
       
        contentView.frame = getScrollViewFrame(scale: scale)
        scrollView.frame = contentView.bounds
        
        let image = item.fullResolutionImage ?? UIImage()
        
        var tItem = item
        var editInfo = tItem.editInfo ?? EditInfo(zoomScale: 1, contentOffset: CGPoint(x: 0, y: 0), scale: scale, mode: .fill)
        imageView.image = image
        imageView.frame = updateFirstImageViewFrame(image: image, editInfo: editInfo)
        scrollView.zoomScale = editInfo.zoomScale
        scrollView.contentSize = imageView.size
        scrollView.contentOffset = editInfo.contentOffset
        var img = captureImageFromView()
        if img?.size.width != UIScreen.main.bounds.width {
            img = img?.scaled(toWidth: UIScreen.main.bounds.width)
        }
        
        editInfo.image = img
        tItem.editInfo = editInfo
        return tItem
    }
    
    func setEditInfoImage(firstScale: Scale, item: AssetItem) -> AssetItem {
        
        contentView.frame = getScrollViewFrame(scale: firstScale)
        scrollView.frame = contentView.bounds

        
        let image = item.fullResolutionImage ?? UIImage()
        
        var tItem = item
        var editInfo = tItem.editInfo ?? EditInfo(zoomScale: 1, contentOffset: CGPoint(x: 0, y: 0), scale: firstScale, mode: .fill)
        
        imageView.image = image
        imageView.frame = updateImageViewFrame(image: image, editInfo: editInfo)
        scrollView.zoomScale = editInfo.zoomScale
        scrollView.contentSize = imageView.size
        scrollView.contentOffset = editInfo.contentOffset
        
        var img = captureImageFromView()
        if img?.size.width != UIScreen.main.bounds.width {
            img = img?.scaled(toWidth: UIScreen.main.bounds.width)
        }
        
        editInfo.image = img
        tItem.editInfo = editInfo
        
        return tItem
    }
}

private extension ScreenshotView {
    
    func updateFirstImageViewFrame(image: UIImage, editInfo: EditInfo) -> CGRect {
        return CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: getImageSize(containerW: scrollView.width, containerH: scrollView.height, image: image)
        )
    }
    
    func updateImageViewFrame(image: UIImage, editInfo: EditInfo) -> CGRect {
        
        let imageW = image.size.width
        let imageH = image.size.height
        
        if editInfo.scale == .oneToOne && imageW != imageH {
            
            if editInfo.mode == .remain {
                return getRemainRect(image: image)
            } else {
                return getFillRect(image: image)
            }
        } else {
            return CGRect(
                origin: CGPoint(x: 0, y: 0),
                size: getImageSize(containerW: scrollView.width, containerH: scrollView.height, image: image)
            )
        }
    }
}

private extension ScreenshotView {
    
    func captureImageFromView() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(contentView.bounds.size, false, UIScreen.main.scale)
        let ctx = UIGraphicsGetCurrentContext()
        contentView.layer.render(in: ctx!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
        
    }
}

extension ScreenshotView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

private extension ScreenshotView {
    
    func configureUI() {
        
        contentView.frame = bounds
        addSubview(contentView)
        
        scrollView.frame = contentView.bounds
        scrollView.delegate = self
        scrollView.bouncesZoom = true
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        contentView.addSubview(scrollView)
        
        imageView.frame = scrollView.bounds
        scrollView.addSubview(imageView)
    }
}

