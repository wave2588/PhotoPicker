//
//  UIViewController+Extension.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/12.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func insert(asChildViewController viewController: UIViewController, at: Int) {
        
        addChild(viewController)
        
        view.insertSubview(viewController.view, at: at)
        
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        viewController.didMove(toParent: self)
    }
    
    func add(asChildViewController viewController: UIViewController, frame: CGRect? = nil) {
        
        addChild(viewController)
        
        view.addSubview(viewController.view)
        
        viewController.view.frame = frame ?? view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        viewController.didMove(toParent: self)
    }
    
    func add(asChildViewController viewController: UIViewController, at view: UIView) {
        
        addChild(viewController)
        
        view.addSubview(viewController.view)
        
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        viewController.didMove(toParent: self)
    }
    
    func remove(asChildViewController viewController: UIViewController) {
        
        viewController.willMove(toParent: nil)
        
        viewController.view.removeFromSuperview()
        
        viewController.removeFromParent()
    }
}
