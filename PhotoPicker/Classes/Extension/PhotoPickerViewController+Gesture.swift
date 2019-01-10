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
                    
                    let eventId = newY == minY ? "PO-ACTION-08" : "PO-ACTION-09"
                    PhotoPickerConfigManager.shared.statistics?(eventId, nil)
                }
            }
            .disposed(by: rx.disposeBag)
        actionVC.topView.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.rx.event
            .bind { [unowned self] _ in
                if self.actionVC.view.y != Runtime.statusBarHeight + 6 {
                    impactFeedback(style: .light)
                }
                self.showActionVC(isHidden: true)
            }
            .disposed(by: rx.disposeBag)
        actionVC.albumTitleView.addGestureRecognizer(tapGesture)
        let tapGesture2 = UITapGestureRecognizer()
        tapGesture2.rx.event
            .bind { [unowned self] _ in
                if self.actionVC.view.y != Runtime.statusBarHeight + 6 {
                    impactFeedback(style: .light)
                }
                self.showActionVC(isHidden: true)
            }
            .disposed(by: rx.disposeBag)
        actionVC.topLineView.addGestureRecognizer(tapGesture2)
    }
    
    func configureShadowView() {
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.rx.event
            .bind { [unowned self] _ in
                impactFeedback(style: .light)
                self.dismissActionVC(isRool: true)
            }
            .disposed(by: rx.disposeBag)
        shadowView.addGestureRecognizer(tapGesture)
    }
    
    func showActionVC(isHidden: Bool) {
        
        let minY: CGFloat = Runtime.statusBarHeight + 6
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.actionVC.view.y = minY
            self.actionVC.view.height = self.view.height - minY
            if isHidden {
                self.actionVC.albumListContainerView.alpha = self.actionVC.albumListContainerView.alpha == 1 ? 0 : 1
                self.actionVC.albumTitleView.imgView.image = self.actionVC.albumListContainerView.alpha == 1 ? UIImage.loadLocalImagePDF(name: "ic_arrow_down.pdf") : UIImage.loadLocalImagePDF(name: "ic_arrow_up.pdf")
            }
            self.shadowView.alpha = 0.5
            if !Runtime.isiPhoneX {
                self.actionVC.topViewHeightCos.constant = 64
                self.actionVC.view.layoutIfNeeded()
            }
        }, completion: { _ in
        })
    }
    
    func dismissActionVC(isRool: Bool) {
        
        let originalY: CGFloat = editContainerView.bottom
        
        /// 如果 actionVC 当前位置已经在最下边, 则再点击后不需要再 dismissActionVC
        if originalY == actionVC.view.y {
            return
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            if !Runtime.isiPhoneX {
                self.actionVC.topViewHeightCos.constant = 25
                self.actionVC.view.layoutIfNeeded()
            }
            
            self.actionVC.view.y = originalY
            self.actionVC.view.height = self.view.height - originalY
            
            self.shadowView.alpha = 0
        }, completion: { _ in
            if isRool {
                self.actionVC.assetListVC.inputs.rollToTop()
            }
        })
    }
}

extension PhotoPickerViewController {
    
    func configurePanGesture() {
        
        let kHeight = UIScreen.main.bounds.height
        
        var beganOffset = CGPoint(x: 0, y: 0)
        var shouldHoldContainer: Bool = false

        let gestureView = actionVC.assetListVC.collectionView!
        let panGesture = actionVC.assetListVC.collectionView.panGestureRecognizer
        panGesture.rx.event
            .bind { [unowned self] gesture in
                
                let minY: CGFloat = Runtime.statusBarHeight + 6
                let maxY: CGFloat = self.editContainerView.bottom

                if self.actionVC.view.top == maxY {
                    return
                }
                
                if gesture.state == .began {
                    beganOffset = self.actionVC.assetListVC.collectionView.contentOffset
                    shouldHoldContainer = beganOffset.y <= 0
                } else if gesture.state == .changed {
                    let point = gesture.translation(in: self.view)
                    
                    if gestureView.contentOffset.y >= 0, shouldHoldContainer == false {
                        if point.y > 0, beganOffset.y <= 0 {
                            gestureView.contentOffset = CGPoint(x: 0, y: 0)
                        }
                        return
                    }
                    shouldHoldContainer = true
                    var top = self.actionVC.view.top + point.y - beganOffset.y
                    top = top >= maxY ? maxY : top
                    top = top <= minY ? minY : top
                    beganOffset.y = 0
                    if top > minY {
                        gestureView.contentOffset = CGPoint(x: 0, y: 0)
                        self.actionVC.view.top = top
                        self.actionVC.view.height = self.view.height - top
                        panGesture.setTranslation(.zero, in: self.view)
                        /// 如果在拖动过程中, 发现已经过了屏幕的50%, 则直接停止手势响应.
                        if top >= kHeight * 0.5 {
                            gesture.isEnabled = false
                        }
                    }
                } else {
                    gesture.isEnabled = true
                    if gestureView.contentOffset.y <= 0 {
                        let y = self.actionVC.view.top + project(initialVelocity: gesture.velocity(in: gestureView).y, decelerationRate: UIScrollView.DecelerationRate.fast.rawValue)
                        if y <= kHeight * 0.5 {
                            self.showActionVC(isHidden: false)
                        } else {
                            self.dismissActionVC(isRool: false)
                        }
                    }
                }
            }
            .disposed(by: rx.disposeBag)
    }
}
