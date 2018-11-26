//
//  EditView+Extension.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/19.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

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


