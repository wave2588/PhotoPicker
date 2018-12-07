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
        dividerView.outputs.isHidden(hidden: false)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateDividerView(scrollView: scrollView)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        dividerView.outputs.isHidden(hidden: true)
        updateEditedAssetItem()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        updateDividerView(scrollView: scrollView)
        dividerView.outputs.isHidden(hidden: false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        dividerView.outputs.isHidden(hidden: true)
        if decelerate == false {
            updateEditedAssetItem()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        dividerView.outputs.isHidden(hidden: true)
        updateEditedAssetItem()
    }
}


extension EditView {
    
    func updateDividerView(scrollView: UIScrollView) {
        
        var x = -scrollView.contentOffset.x
        var y = -scrollView.contentOffset.y
        var w = imageView.width
        var h = imageView.height

        x = x < 0 ? 0 : x
        y = y < 0 ? 0 : y
        w = w > scrollView.width ? scrollView.width : w
        h = h > scrollView.height ? scrollView.height : h
        
        dividerView.left = scrollView.left + x
        dividerView.top = scrollView.top + y
        dividerView.width = w
        dividerView.height = h
    }
    
}
