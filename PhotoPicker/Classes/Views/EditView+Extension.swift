//
//  EditView+Extension.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/19.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

/// 切换容器比例
extension EditView {
//    假设:
//    任意容器    450*300        1.5
//    任意图片1   800*900        0.888..
//    任意图片2   900*400        2.25
//    容器比      float scale =450/300;        1.5
//    图片比例    float imgscale=800/900        0.888
//
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
    
    /// 切换任意比例...
    func getSwitchScaleImageSize(containerSize: CGSize, image: UIImage) -> CGSize {
        
        let imageW = image.size.width
        let imageH = image.size.height
        
        let containerRatio = containerSize.width / containerSize.height
        let aspectRatio = imageW / imageH
        
        if containerRatio > aspectRatio {
            
            let w = imageW / (imageH / containerSize.height)
            debugPrint(w)
            
        } else {
            
        }
        
//        debugPrint(containerRatio, aspectRatio, scrollView.frame)
        debugPrint(scrollView.frame)
        
        return CGSize(width: 0, height: 0)
    }
}

extension EditView {
    
    /// 留白
    func getRemainRect(image: UIImage) -> CGRect {
        
        let imageW = image.size.width
        let imageH = image.size.height
        
        if imageW < width || imageH < height {
            return CGRect(x: 0, y: 0, width: width, height: height)
        } else {
            if imageW > imageH {
                let imageViewH = height * scale
                let ratio = imageViewH / imageH
                let imageViewW = imageW * ratio
                return CGRect(x: 0, y: (height - imageViewH) * 0.5, width: imageViewW, height: imageViewH)
            } else if imageW < imageH {
                let imageViewW = width * scale
                let ratio = imageViewW / imageW
                let imageViewH = imageH * ratio
                return CGRect(x: (width - imageViewW) * 0.5, y: 0, width: imageViewW, height: imageViewH)
            }
        }
        return CGRect(x: 0, y: 0, width: width, height: height)
    }
    
    /// 充满
    func getFillSize(image: UIImage) -> CGSize {
        
        let imageW = image.size.width
        let imageH = image.size.height
        
        /// 图片宽度和高度都想小于容器的情况, 暂时没考虑..
        if imageW < width || imageH < height {
            return CGSize(width: width, height: height)
        } else if imageW > imageH {
            let ratio = height / imageH
            let imageViewW = imageW * ratio
            let imageViewH = imageH * ratio
            return CGSize(width: imageViewW, height: imageViewH)
        } else {
            let ratio = width / imageW
            let imageViewW = imageW * ratio
            let imageViewH = imageH * ratio
            return CGSize(width: imageViewW, height: imageViewH)
        }
    }
}

extension EditView {
    
    func getImageViewSize(scale: Scale, image: UIImage) -> CGSize {
        
        let imageW = image.size.width
        let imageH = image.size.height
        
        var newImageW: CGFloat = width
        var newImageH: CGFloat = height

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
        
        if scale == .oneToOne {
            if imageW == imageH {
            } else if imageW > imageH {
                let scale = height / imageH
                newImageH = imageH * scale
                newImageW = imageW * scale
            } else if imageW < imageH {
                let scale = width / imageW
                newImageH = imageH * scale
                newImageW = imageW * scale
            }
        } else if scale == .fourToThreeHorizontal {
            getFourToThreeSize()
        } else if scale == .fourToThreeVertical {
            getFourToThreeSize()
        }
        return CGSize(width: newImageW, height: newImageH)
    }
}

extension EditView {
    
    func getPreviewImageSize(image: UIImage) -> CGSize {
        
        let imageW = image.size.width
        let imageH = image.size.height
        
        var newImageW: CGFloat = width
        var newImageH: CGFloat = height
        
        if imageW == imageH {
            /// 1:1
        } else if imageW > imageH {
            let ratio = height / imageH
            newImageH = imageH * ratio
            newImageW = imageW * ratio
        } else if imageW < imageH {
            let ratio = width / imageW
            newImageH = imageH * ratio
            newImageW = imageW * ratio
        }
        return CGSize(width: newImageW, height: newImageH)
    }
}


