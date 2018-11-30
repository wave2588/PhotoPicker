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
}

extension EditView {
    
    /// 留白
    func getRemainRect(image: UIImage) -> CGRect {
        
        let imageW = image.size.width
        let imageH = image.size.height
        
        if imageW > imageH {
            let containerH = height * scale
            let containerW = width
            let size = getImageSize(containerW: containerW, containerH: containerH, image: image)
            return CGRect(x: 0, y: (height - size.height) * 0.5, width: size.width, height: size.height)
        } else {
            let containerW = width * scale
            let containerH = height
            let size = getImageSize(containerW: containerW, containerH: containerH, image: image)
            return CGRect(x: (width - size.width) * 0.5, y: 0, width: size.width, height: size.height)
        }
    }
    
    /// 充满
    func getFillRect(image: UIImage) -> CGRect {
        let size = getImageSize(containerW: scrollView.width, containerH: scrollView.height, image: image)
        return CGRect(x: 0, y: 0, width: size.width, height: size.height)
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

/// PreView Image Size
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

/// ScrollView Frame
extension EditView {
    
    func getScrollViewFrame(editInfo: EditInfo) -> CGRect {
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        var w: CGFloat = width
        var h: CGFloat = height
        if editInfo.scale == .oneToOne {
        } else if editInfo.scale == .fourToThreeHorizontal {
            let newScrollViewH = scrollView.height * scale
            let space = (scrollView.height - newScrollViewH) * 0.5
            y = space
            h = height - space * 2
        } else if editInfo.scale == .fourToThreeVertical {
            let newScrollViewW = scrollView.width * scale
            let space = (scrollView.width - newScrollViewW) * 0.5
            x = space
            w = width - space * 2
        }
        return CGRect(x: x, y: y, width: w, height: h)
    }
}
