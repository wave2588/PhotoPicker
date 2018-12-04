//
//  PhotoPickerActionViewController+Gesture.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/30.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

extension PhotoPickerViewController {
    
    func configureActionVCGesture() {
        
        let originalY: CGFloat = editContainerView.bottom + Runtime.statusBarHeight
        let minY: CGFloat = Runtime.statusBarHeight + 100
        let panGesture = UIPanGestureRecognizer()
        panGesture.rx.event
            .bind { [unowned self] gesture in
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
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 4, options: .curveEaseOut, animations: {
                    self.actionVC.view.y = minY
                    self.actionVC.view.height = self.view.height - minY
                    self.actionVC.albumListContainerView.alpha = self.actionVC.albumListContainerView.alpha == 1 ? 0 : 1
                    self.actionVC.albumTitleView.imgView.image = self.actionVC.albumListContainerView.alpha == 1 ? UIImage.loadLocalImage(name: "ic_arrow_down.jpg") : UIImage.loadLocalImage(name: "ic_arrow_up.jpg")
                    self.shadowView.alpha = 0.5
                    if !Runtime.isiPhoneX {
                        self.actionVC.topViewHeightCos.constant = 64
                        self.actionVC.view.layoutIfNeeded()
                    }
                }, completion: { _ in
                })
            }
            .disposed(by: rx.disposeBag)
        actionVC.albumTitleView.addGestureRecognizer(tapGesture)
        let tapGesture2 = UITapGestureRecognizer()
        tapGesture2.rx.event
            .bind { [unowned self] _ in
                self.actionVC.albumTitleView.imgView.image = UIImage.loadLocalImage(name: "ic_arrow_down.jpg")
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 4, options: .curveEaseOut, animations: {
                    self.actionVC.view.y = minY
                    self.actionVC.view.height = self.view.height - minY
                    self.actionVC.albumListContainerView.alpha = self.actionVC.albumListContainerView.alpha == 1 ? 0 : 1
                    self.actionVC.albumTitleView.imgView.image = self.actionVC.albumListContainerView.alpha == 1 ? UIImage.loadLocalImage(name: "ic_arrow_down.jpg") : UIImage.loadLocalImage(name: "ic_arrow_up.jpg")
                    self.shadowView.alpha = 0.5
                    if !Runtime.isiPhoneX {
                        self.actionVC.topViewHeightCos.constant = 64
                        self.actionVC.view.layoutIfNeeded()
                    }
                }, completion: { _ in
                })
            }
            .disposed(by: rx.disposeBag)
        actionVC.topLineView.addGestureRecognizer(tapGesture2)
    }
    
    func configureShadowView() {
        
        let originalY: CGFloat = editContainerView.bottom + Runtime.statusBarHeight
        let tapGesture = UITapGestureRecognizer()
        tapGesture.rx.event
            .bind { [unowned self] _ in
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 4, options: .curveEaseOut, animations: {
                    if !Runtime.isiPhoneX {
                        self.actionVC.topViewHeightCos.constant = 25
                        self.actionVC.view.layoutIfNeeded()
                    }
                    self.actionVC.view.y = originalY
                    self.actionVC.view.height = self.view.height - originalY
                    self.shadowView.alpha = 0
                }, completion: { _ in
                })
            }
            .disposed(by: rx.disposeBag)
        shadowView.addGestureRecognizer(tapGesture)
    }
    
}
