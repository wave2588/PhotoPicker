//
//  UIView+Extension.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/12.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit
import SwifterSwift

extension UIView {

    static func fromNib<T: UIView>() -> T {

        if PhotoPickerConfigManager.shared.isDebug {
            return Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)?.first as! T
        }
        
        let path = Bundle.main.path(forResource: "Frameworks/PhotoPicker", ofType: "framework")
        let bundle = Bundle(path: path!)
        
        let name = String(describing: self)
        let view = UINib(nibName: name, bundle: bundle).instantiate(withOwner: nil, options: nil).first as! T
        return view
    }
}
