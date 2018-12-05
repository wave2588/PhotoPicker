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
    
    func setEditInfoImage(firstEditInfo: EditInfo, item: AssetItem) -> AssetItem {
        
//        contentView.frame = updateContentView(scale: firstEditInfo.scale)
//        scrollView.frame = updateScrollViewFrame(scale: firstEditInfo.scale)
        
        updateFrame(scale: firstEditInfo.scale)
        
        let image = item.fullResolutionImage ?? UIImage()
        
        var tItem = item
        var editInfo = tItem.editInfo ?? EditInfo(zoomScale: 1, contentOffset: CGPoint(x: 0, y: 0), scale: firstEditInfo.scale, mode: .fill)
        
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

/// 不存在 fourToThreeHorizontal 的情况, 如果是则转成 oneToOne
private extension ScreenshotView {
    
    func updateFrame(scale: Scale) {
        
        let width = UIScreen.main.bounds.width
        let height = width
        
        if scale == .oneToOne {
            
            contentView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            scrollView.frame = contentView.bounds
            
        } else if scale == .fourToThreeHorizontal {
            
            contentView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            let newScrollViewH = height * SCALE
            let space = (height - newScrollViewH) * 0.5
            let y = space
            let h = height - space * 2
            scrollView.frame = CGRect(x: x, y: y, width: width, height: h)
            
        } else if scale == .fourToThreeVertical {
            
            let newScrollViewW = width * SCALE
            let space = (width - newScrollViewW) * 0.5
            let x = space
            let w = width - space * 2
            contentView.frame = CGRect(x: x, y: 0, width: w, height: height)
            scrollView.frame = contentView.bounds
        }
    }
}

private extension ScreenshotView {
    
    func configureUI() {
        
        contentView.backgroundColor = UIColor.blue
        
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

