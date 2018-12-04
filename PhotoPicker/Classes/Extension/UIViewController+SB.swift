//
//  UIViewController+SB.swift
//  PhotoPicker
//
//  Created by wave on 2018/12/4.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

extension UIViewController {
    
    static func fromStoryboard<T: UIViewController>() -> T {
        
        let vcName = String(describing: self)

        if PhotoPickerConfigManager.shared.isDebug {
            return UIStoryboard(name: "PhotoPicker", bundle: nil).instantiateViewController(withIdentifier: vcName) as! T
        }
        
        let path = Bundle.main.path(forResource: "Frameworks/PhotoPicker", ofType: "framework")
        let bundle = Bundle(path: path!)
        let sb = UIStoryboard(name: "PhotoPicker", bundle:bundle)
        let vc = sb.instantiateViewController(withIdentifier: vcName)
        return vc as! T
    }
}
