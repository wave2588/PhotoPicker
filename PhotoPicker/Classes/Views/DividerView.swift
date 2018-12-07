//
//  DividerView.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/15.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

protocol DividerViewOutputs {
    func isHidden(hidden: Bool)
}

class DividerView: UIView {

    var outputs: DividerViewOutputs { return self }
    
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
//        horizontalOne.backgroundColor = .red
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
        
        let lineW: CGFloat = 1
        
        horizontalOne.frame = CGRect(x: 0, y: height * 1 / 3, width: width, height: lineW)
        horizontalTwo.frame = CGRect(x: 0, y: height * 2 / 3, width: width, height: lineW)
        
        verticalOne.frame = CGRect(x: width * 1 / 3, y: 0, width: lineW, height: height)
        verticalTwo.frame = CGRect(x: width * 2 / 3, y: 0, width: lineW, height: height)
    }
}

extension DividerView: DividerViewOutputs {
    
    func isHidden(hidden: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.alpha = hidden ? 0 : 1
        }
    }
}
