//
//  UIImage+Extension.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/27.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

extension UIImage {
    
    static func loadLocalImage(name: String) -> UIImage {
        
        guard let path = Bundle.main.resourcePath?.appendingPathComponent(name) else {
            return UIImage()
        }
        
        let img = UIImage(contentsOfFile: path) ?? UIImage()
        return img
    }
}

