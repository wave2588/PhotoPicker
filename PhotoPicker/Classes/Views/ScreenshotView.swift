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
        
        updateScrollView(editInfo: firstEditInfo)
        
        let image = item.fullResolutionImage ?? UIImage()
        
        var tItem = item
        var editInfo = tItem.editInfo ?? EditInfo(zoomScale: 1, contentOffset: CGPoint(x: 0, y: 0), scale: firstEditInfo.scale, mode: .fill)
        
        imageView.image = image
        imageView.size = updateImageView(image: image, editInfo: editInfo)
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
    
    func updateScrollView(editInfo: EditInfo) {
        //        if editInfo.scale == .oneToOne {
        //            scrollView.top = 0
        //            scrollView.left = 0
        //            scrollView.width = width
        //            scrollView.height = height
        //        } else if editInfo.scale == .fourToThreeHorizontal {
        //            let newScrollViewH = scrollView.height * scale
        //            let space = (scrollView.height - newScrollViewH) * 0.5
        //            scrollView.top = space
        //            scrollView.height = height - space * 2
        //        } else if editInfo.scale == .fourToThreeVertical {
        //            let newScrollViewW = scrollView.width * scale
        //            let space = (scrollView.width - newScrollViewW) * 0.5
        //            scrollView.left = space
        //            scrollView.width = width - space * 2
        //        }
        
        if editInfo.scale == .oneToOne {
            contentView.top = 0
            contentView.left = 0
            contentView.width = width
            contentView.height = height
        } else if editInfo.scale == .fourToThreeHorizontal {
            let newScrollViewH = contentView.height * scale
            let space = (contentView.height - newScrollViewH) * 0.5
            contentView.top = space
            contentView.height = height - space * 2
        } else if editInfo.scale == .fourToThreeVertical {
            let newScrollViewW = contentView.width * scale
            let space = (contentView.width - newScrollViewW) * 0.5
            contentView.left = space
            contentView.width = width - space * 2
        }
        scrollView.frame = contentView.bounds
    }
    
    func updateImageView(image: UIImage, editInfo: EditInfo) -> CGSize {
        
        let imageW = image.size.width
        let imageH = image.size.height
        
        var newImageW: CGFloat = scrollView.width
        var newImageH: CGFloat = scrollView.height
        
        func getFourToThreeSize() {
            if imageW == imageH {
            } else if imageW > imageH {
                let scale = scrollView.height / imageH
                newImageH = imageH * scale
                newImageW = imageW * scale
            } else if imageW < imageH {
                let scale = scrollView.width / imageW
                newImageH = imageH * scale
                newImageW = imageW * scale
            }
        }
        
        if editInfo.scale == .oneToOne {
            if imageW == imageH {
            } else {
                if imageW > imageH {
                    if editInfo.mode == .remain {
                        newImageH = height * scale
                        let ratio = newImageH / imageH
                        newImageW = imageW * ratio
                        imageView.top = (height - newImageH) * 0.5
                        imageView.left = 0
                    } else {
                        let ratio = height / imageH
                        newImageW = imageW * ratio
                        newImageH = imageH * ratio
                    }
                } else if imageW < imageH {
                    if editInfo.mode == .remain {
                        newImageW = width * scale
                        let ratio = newImageW / imageW
                        newImageH = imageH * ratio
                        imageView.top = 0
                        imageView.left = (width - newImageW) * 0.5
                    } else {
                        let ratio = width / imageW
                        newImageW = imageW * ratio
                        newImageH = imageH * ratio
                    }
                }
            }
            
        } else if editInfo.scale == .fourToThreeHorizontal {
            getFourToThreeSize()
        } else if editInfo.scale == .fourToThreeVertical {
            getFourToThreeSize()
        }
        return CGSize(width: newImageW, height: newImageH)
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

