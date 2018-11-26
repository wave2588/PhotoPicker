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
        
        horizontalOne.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        horizontalTwo.backgroundColor = horizontalOne.backgroundColor
        verticalOne.backgroundColor = horizontalOne.backgroundColor
        verticalTwo.backgroundColor = horizontalOne.backgroundColor
        
        update(width: width, height: height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        update(width: width, height: height)
    }
    
    func update(width: CGFloat, height: CGFloat) {
        
        horizontalOne.frame = CGRect(x: 0, y: height * 1 / 3, width: width, height: 1)
        horizontalTwo.frame = CGRect(x: 0, y: height * 2 / 3, width: width, height: 1)
        
        verticalOne.frame = CGRect(x: width * 1 / 3, y: 0, width: 1, height: height)
        verticalTwo.frame = CGRect(x: width * 2 / 3, y: 0, width: 1, height: height)
    }
    
    
}
