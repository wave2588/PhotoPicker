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
        
        updateDividerView(scrollView: scrollView)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        dividerView.alpha = 0
        updateEditedAssetItem()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dividerView.alpha = 1
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            dividerView.alpha = 0
            updateEditedAssetItem()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        dividerView.alpha = 0
        updateEditedAssetItem()
    }
}


extension EditView {
    
    func updateDividerView(scrollView: UIScrollView) {
        
//        [button setFrame:CGRectMake(scaleX *scale- button.frame.size.width/2 + mapImageView.frame.origin.x,scaleY *scale - button.frame.size.height + mapImageView.frame.origin.y,button.frame.size.width,button.frame.size.height)];
//
//                        [button setHidden:NO];
//
//                  }];
        
        var x = -scrollView.contentOffset.x
        var y = -scrollView.contentOffset.y
        var w = imageView.width
        var h = imageView.height
        
        x = x < 0 ? 0 : x
        y = y < 0 ? 0 : y
        
        debugPrint(x, y, imageView.width, imageView.height)

        
        
        /// 计算出当前显示出来的图片 宽 and 高 
        
        let zoomScale = scrollView.zoomScale
        let oriImgSize = CGSize(width: imageView.width / zoomScale, height: imageView.height / zoomScale)
        
        let scrollViewW = scrollView.width
        let scrollViewH = scrollView.height
        
        if imageView.width <= scrollViewW && imageView.height <= scrollViewH {             /// 宽 and 高 都没有超出
            debugPrint("宽和高都没有超出")
            dividerView.frame = CGRect(x: -scrollView.contentOffset.x, y: -scrollView.contentOffset.y, width: imageView.width, height: imageView.height)
        } else if imageView.width > scrollViewW && imageView.height < scrollViewH {        /// 宽超出,  高没有超出
            debugPrint("宽超出, 高没有超出", scrollView.contentOffset)
            var x: CGFloat = -scrollView.contentOffset.x
            var y: CGFloat = -scrollView.contentOffset.y
            let w = scrollView.width - x
            dividerView.frame = CGRect(x: x, y: y, width: w, height: imageView.height)
        }else if imageView.width < scrollViewW && imageView.height > scrollViewH {         /// 宽没有超出, 高超出
            debugPrint("宽没有超出, 高超出", scrollView.contentOffset)
            var x: CGFloat = -scrollView.contentOffset.x
            var y: CGFloat = -scrollView.contentOffset.y
            if scrollView.contentOffset.x >= 0 {
                x = 0
            }
            if scrollView.contentOffset.y >= 0 {
                y = 0
            }
            dividerView.frame = CGRect(x: x, y: y, width: imageView.width, height: scrollViewH)
        }else if imageView.width > scrollViewW && imageView.height > scrollViewH {         /// 宽 and 高 都超出
            debugPrint("宽 and 高 都超出")
            dividerView.frame = CGRect(x: 0, y: 0, width: scrollViewW, height: scrollViewH)
        }
    }
    
}
