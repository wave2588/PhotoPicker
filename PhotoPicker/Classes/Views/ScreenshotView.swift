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
        
        contentView.frame = getScrollViewFrame(scale: firstEditInfo.scale)
        scrollView.frame = contentView.bounds
        
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
        
        /* test code
        /// 通过下边这几行代码, 可以判断出来 ScrollView确实是在一个正确的位置
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .red
        UIApplication.shared.keyWindow?.addSubview(view)
        //        view.addSubview(scrollView)
        scrollView.backgroundColor = .blue
        
        let gesture = UITapGestureRecognizer()
        gesture.rx.event.bind { _ in
            view.removeFromSuperview()
            }.disposed(by: view.rx.disposeBag)
        view.addGestureRecognizer(gesture)
        
        
        /// 但是把截图出来的图, 放到一个imageView上边就不对了
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: img?.size.width ?? 100, height: img?.size.height ?? 100))
        imgView.image = img
        imgView.backgroundColor = .yellow
        view.addSubview(imgView)
         */
        
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

