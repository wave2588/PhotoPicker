//
//  UIView+Extension.swift
//  PhotoPicker_Example
//
//  Created by wave on 2018/12/5.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import PhotoPicker

extension UIView {
    
    static func fromNibsss<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)?.first as! T
    }
}

extension UIViewController {
    func hideStatusBar() {
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.alpha = 0
    }
}
