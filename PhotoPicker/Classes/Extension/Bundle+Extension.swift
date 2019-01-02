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
        
        return nil
    }

}
