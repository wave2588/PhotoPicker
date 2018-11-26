//
//  Storyboard.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/26.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

enum Storyboard: String {
    
    case photo = "PhotoPicker"
    
    
    var storyboard: UIStoryboard {
        return UIStoryboard(name: rawValue, bundle: nil)
    }
    
    func get<T: UIViewController>(class name: T.Type) -> T {
        return storyboard.instantiateViewController(withClass: name)!
    }
    
}
