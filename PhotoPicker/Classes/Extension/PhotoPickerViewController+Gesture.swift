//
//  PhotoPickerActionViewController+Gesture.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/30.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit
import RxGesture
import RxCocoa
import RxSwift

extension PhotoPickerViewController {
    
    func configureActionVCGesture() {
        
        let minY: CGFloat = Runtime.statusBarHeight + 6
        let panGesture = UIPanGestureRecognizer()
        panGesture.rx.event
            .bind { [unowned self] gesture in
                let originalY: CGFloat = self.editContainerView.bottom
                let translationPotion = gesture.translation(in: self.view)
                if gesture.state == .changed {
                    var newY = self.actionVC.view.y + translationPotion.y
                    newY = newY >= originalY ? originalY : newY
                    newY = newY <= minY ? minY : newY
                    let newH = self.view.height - newY
                    self.actionVC.view.y = newY
                    self.actionVC.view.height = newH
                    gesture.setTranslation(.zero, in: self.actionVC.topView)
                } else if gesture.state == .ended || gesture.state == .failed || gesture.state == .cancelled {
                    let screenCenterY = UIScreen.main.bounds.height * 0.5
                    let newY = self.actionVC.view.y >= screenCenterY ? originalY : minY
                    let newH = self.view.height - newY
                    UIView.animate(withDuration: 0.25, animations: {
                        self.actionVC.view.height = newH
                        self.actionVC.view.y = newY
                        self.shadowView.alpha = newY == minY ? 0.5 : 0
                        if !Runtime.isiPhoneX {
                            if self.shadowView.alpha != 0 {
                                self.actionVC.topViewHeightCos.constant = 64
                            } else {
                                self.actionVC.topViewHeightCos.constant = 25
                            }
                            self.actionVC.view.layoutIfNeeded()
                        }
                    }, completion: { _ in
                    })
                }
            }
            .disposed(by: rx.disposeBag)
        actionVC.topView.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.rx.event
            .bind { [unowned self] _ in
                self.showActionVC()
            }
            .disposed(by: rx.disposeBag)
        actionVC.albumTitleView.addGestureRecognizer(tapGesture)
        let tapGesture2 = UITapGestureRecognizer()
        tapGesture2.rx.event
            .bind { [unowned self] _ in
                self.showActionVC()
            }
            .disposed(by: rx.disposeBag)
        actionVC.topLineView.addGestureRecognizer(tapGesture2)
    }
    
    func configureShadowView() {
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.rx.event
            .bind { [unowned self] _ in
                self.dismissActionVC()
            }
            .disposed(by: rx.disposeBag)
        shadowView.addGestureRecognizer(tapGesture)
    }
    
    func showActionVC() {
        let minY: CGFloat = Runtime.statusBarHeight + 6
        self.actionVC.albumTitleView.imgView.image = UIImage.loadLocalImagePDF(name: "ic_arrow_down.pdf")
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 4, options: .curveEaseOut, animations: {
            self.actionVC.view.y = minY
            self.actionVC.view.height = self.view.height - minY
            self.actionVC.albumListContainerView.alpha = self.actionVC.albumListContainerView.alpha == 1 ? 0 : 1
            self.actionVC.albumTitleView.imgView.image = self.actionVC.albumListContainerView.alpha == 1 ? UIImage.loadLocalImagePDF(name: "ic_arrow_down.pdf") : UIImage.loadLocalImagePDF(name: "ic_arrow_up.pdf")
            self.shadowView.alpha = 0.5
            if !Runtime.isiPhoneX {
                self.actionVC.topViewHeightCos.constant = 64
                self.actionVC.view.layoutIfNeeded()
            }
        }, completion: { _ in
        })
    }
    
    func dismissActionVC() {
        let originalY: CGFloat = editContainerView.bottom
        
        /// 如果 actionVC 当前位置已经在最下边, 则再点击后不需要再 dismissActionVC
        if originalY == actionVC.view.y {
            return
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 4, options: .curveEaseOut, animations: {
            if !Runtime.isiPhoneX {
                self.actionVC.topViewHeightCos.constant = 25
                self.actionVC.view.layoutIfNeeded()
            }
            
            self.actionVC.view.y = originalY
            self.actionVC.view.height = self.view.height - originalY
            
            self.shadowView.alpha = 0
        }, completion: { _ in
            self.actionVC.assetListVC.inputs.rollToTop()
        })
    }
}

extension PhotoPickerViewController {
    
    func configurePanGesture() {
        
        let minY: CGFloat = Runtime.statusBarHeight + 6
        let maxY: CGFloat = editContainerView.bottom

        let kHeight = UIScreen.main.bounds.height
        
//        let panGesture = actionVC.assetListVC.collectionView.panGestureRecognizer
//        panGesture.rx.event
//            .bind { [unowned self] gesture in
//                if gesture.state == .began || gesture.state == .changed {
//                    let point = gesture.translation(in: self.view)
//                    debugPrint("changed", point)
//                    let top = self.actionVC.view.y + point.y
//                    self.actionVC.view.y = top
//                    self.actionVC.view.height = kHeight - top
//                    gesture.setTranslation(.zero, in: self.view)
//                } else {
//                    debugPrint("end")
//                }
//            }
//            .disposed(by: rx.disposeBag)
    }
    
    
//    func configureComment() {
//
//        var shouldHoldContainer: Bool = false
//        var beganOffset = CGPoint(x: 0, y: 0)
//        var originTop = view.height - visualEffectView.height
//        originTop = Runtime.isHighDevice ? originTop - 34 : originTop
//        let tableView = commentVC.list.tableView
//
//        tableView.panGestureRecognizer.rx.event
//            .bind { [unowned self] panGesture in
//
//                let state = panGesture.state
//                if state == .began {
//                    beganOffset = tableView.contentOffset
//                    shouldHoldContainer = beganOffset.y <= 0
//
//                } else if state == .changed {
//                    let point = panGesture.translation(in: self.visualEffectView)
//                    if tableView.contentOffset.y >= 0, shouldHoldContainer == false {
//                        if point.y > 0, beganOffset.y <= 0 {
//                            tableView.contentOffset = CGPoint(x: 0, y: 0)
//                        }
//                        return
//                    }
//                    shouldHoldContainer = true
//                    let top = self.visualEffectView.top + point.y - beganOffset.y
//                    beganOffset.y = 0
//                    if top > originTop {
//                        tableView.contentOffset = CGPoint(x: 0, y: 0)
//                        self.visualEffectView.top = top
//                        panGesture.setTranslation(.zero, in: self.visualEffectView)
//                    }
//
//                } else if state == .ended || state == .failed || state == .cancelled {
//                    var top = originTop
//                    let y = self.visualEffectView.top + project(initialVelocity: panGesture.velocity(in: tableView).y, decelerationRate: UIScrollView.DecelerationRate.fast.rawValue)
//                    if y > UIScreen.main.bounds.height * 0.4 {
//                        top = UIScreen.main.bounds.height
//                    }
//                    UIView.animate(withDuration: 0.25, animations: {
//                        self.visualEffectView.top = top
//                    }, completion: { _ in
//                        if self.visualEffectView.top == UIScreen.main.bounds.height {
//                            self.dismiss(animated: false, completion: {
//                                self.visualEffectView.top = originTop
//                            })
//                        }
//                    })
//                }
//            }
//            .disposed(by: rx.disposeBag)
//
//        post
//            .bind(to: commentVC.inputs.post)
//            .disposed(by: rx.disposeBag)
//    }

}
