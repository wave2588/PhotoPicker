//
//  EditView+Extension.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/19.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit


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
    
    func getScrollViewFrame(scale: Scale) -> CGRect {
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        var w: CGFloat = width
        var h: CGFloat = height
        if scale == .oneToOne {
        } else if scale == .fourToThreeHorizontal {
            let newScrollViewH = scrollView.height * SCALE
            let space = (scrollView.height - newScrollViewH) * 0.5
            y = space
            h = height - space * 2
        } else if scale == .fourToThreeVertical {
            let newScrollViewW = scrollView.width * SCALE
            let space = (scrollView.width - newScrollViewW) * 0.5
            x = space
            w = width - space * 2
        }
        return CGRect(x: x, y: y, width: w, height: h)
    }
}
