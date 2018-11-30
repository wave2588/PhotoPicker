//
//  EditView+Delegate.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/30.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

extension EditView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        dividerView.alpha = 1
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        /*
         修改 dividerView 的 frame
         判断宽或高 有一个是否超出屏幕, 如果超出则按照屏幕的最大宽或者高
         如果没有超出, 则按照iamgeView的宽高
         */
        if imageView.width <= width || imageView.height <= height {
        } else {
        }
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        dividerView.alpha = 0
        updateEditedAssetItem()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            updateEditedAssetItem()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateEditedAssetItem()
    }
}
