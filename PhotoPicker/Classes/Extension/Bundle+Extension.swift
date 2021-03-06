//
//  String+Extension.swift
//  PhotoPicker
//
//  Created by wave on 2019/1/2.
//  Copyright © 2019 wave. All rights reserved.
//

import UIKit

extension Bundle {
    
    static func resourcePath(_ name: String) -> String? {
        if PhotoPickerConfigManager.shared.isDebug {
            return Bundle.main.path(forResource: name, ofType: nil)
        }
        
        let bundlePath = Bundle.main.path(forResource: "Frameworks/PhotoPicker", ofType: "framework")
        guard let path = bundlePath?.appendingPathComponent(name) else {
            return nil
        }
        return path
    }

}
