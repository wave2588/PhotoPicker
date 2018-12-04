//
//  UIView+Frame.swift
//  PhotoPicker
//
//  Created by wave on 2018/12/4.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

extension UIView {
    
    var centerX: CGFloat{
        set{
            self.center = CGPoint(x: newValue, y: self.center.y)
        }
        get{
            return self.center.x
        }
    }
    
    var centerY: CGFloat {
        set{
            self.center = CGPoint(x: self.center.x, y: newValue)
        }
        get{
            return self.center.y
        }
    }
    
    var left: CGFloat {
        set{
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
        get{
            return self.frame.origin.x
        }
    }
    
    var top: CGFloat {
        set{
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
        get{
            return self.frame.origin.y
        }
    }
    
    var right: CGFloat {
        set{
            var frame = self.frame
            frame.origin.x = newValue - frame.size.width
            self.frame = frame
        }
        get{
            return self.frame.origin.x + self.frame.size.width
        }
    }
    
    var bottom: CGFloat {
        set{
            var frame = self.frame
            frame.origin.y = newValue - frame.size.height
            self.frame = frame
        }
        get{
            return self.frame.origin.y + self.frame.size.height
        }
    }
}
