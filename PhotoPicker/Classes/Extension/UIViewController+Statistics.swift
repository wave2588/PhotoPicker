//
//  UIViewController+Statistics.swift
//  PhotoPicker
//
//  Created by wave on 2019/1/10.
//  Copyright © 2019 wave. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxViewController

extension Reactive where Base: UIViewController {
    
    var visibleDuration: Observable<TimeInterval> {
        
        return Observable
            .zip(
                base.rx.viewWillAppear.map { _ in Date() },
                base.rx.viewWillDisappear
            )
            .map { date, _ in Date().timeIntervalSince1970 - date.timeIntervalSince1970 }
    }
}

