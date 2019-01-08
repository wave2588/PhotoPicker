//
//  ProjectFunction.swift
//  PhotoPicker
//
//  Created by wave on 2019/1/8.
//  Copyright © 2019 wave. All rights reserved.
//

import UIKit

func project(initialVelocity: CGFloat, decelerationRate: CGFloat) -> CGFloat {
    return (initialVelocity / 1000.0) * decelerationRate / (1.0 - decelerationRate)
}
