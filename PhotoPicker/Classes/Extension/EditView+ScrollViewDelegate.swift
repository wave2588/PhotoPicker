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
//        debugPrint("contentOffset--->: \(scrollView.contentOffset)    contentSize--->: \(scrollView.contentSize)" )
//        debugPrint("容器大小--->: ", self.imageView.size)
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
        if imageView.x != 0 || imageView.y != 0 {
            w = scrollView.width
            h = scrollView.height
            
            let tx = imageView.x - scrollView.contentOffset.x
            x = tx < 0 ? 0 : tx
            let ty = imageView.y - scrollView.contentOffset.y
            y = ty < 0 ? 0 : ty
            w = w > imageView.width ? imageView.width : w
            h = h > imageView.height ? imageView.height : h
        } else {
            x = x < 0 ? 0 : x
            y = y < 0 ? 0 : y
            w = w > scrollView.width ? scrollView.width : w
            h = h > scrollView.height ? scrollView.height : h
        }
        
        let rect = CGRect(x: scrollView.left + x, y: scrollView.top + y, width: w, height: h)
        dividerView.outputs.setFrame(frame: rect)
    }
    
}
