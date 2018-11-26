//
//  DividerView.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/15.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

class DividerView: UIView {

    /// 画 四根线
    private let horizontalOne = UIView()
    private let horizontalTwo = UIView()
    
    private let verticalOne = UIView()
    private let verticalTwo = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        isUserInteractionEnabled = false
        
        addSubview(horizontalOne)
        addSubview(horizontalTwo)
        addSubview(verticalOne)
        addSubview(verticalTwo)
        
        horizontalOne.backgroundColor = .red
        horizontalTwo.backgroundColor = .red
        verticalOne.backgroundColor = .red
        verticalTwo.backgroundColor = .red
        
        horizontalOne.frame = CGRect(x: 0, y: (height * 0.5 - 1) * 0.5, width: width, height: 1)
        horizontalTwo.frame = CGRect(x: 0, y: (height * 0.5 - 1) * 0.5 + height * 0.5, width: width, height: 1)
        
        verticalOne.frame = CGRect(x: (width * 0.5 - 1) * 0.5, y: 0, width: 1, height: height)
        verticalTwo.frame = CGRect(x: (width * 0.5 - 1) * 0.5 + width * 0.5, y: 0, width: 1, height: height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(width: CGFloat, height: CGFloat) {
        
        horizontalOne.frame = CGRect(x: 0, y: (height * 0.5 - 1) * 0.5, width: width, height: 1)
        horizontalTwo.frame = CGRect(x: 0, y: (height * 0.5 - 1) * 0.5 + height * 0.5, width: width, height: 1)
        
        verticalOne.frame = CGRect(x: (width * 0.5 - 1) * 0.5, y: 0, width: 1, height: height)
        verticalTwo.frame = CGRect(x: (width * 0.5 - 1) * 0.5 + width * 0.5, y: 0, width: 1, height: height)
    }
    
    
}
