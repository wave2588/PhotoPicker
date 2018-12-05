//
//  ThreeViewController.swift
//  PhotoPicker
//
//  Created by wave on 2018/12/1.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit
import PhotoPicker

class ThreeViewController: UIViewController {

    deinit {
        debugPrint("deinit \(self)")
    }
    
    var item: (Scale, [UIImage])!
    
    let scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        configureScrollView()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }
}

private extension ThreeViewController {
    
    func configureScrollView() {
        
        view.addSubview(scrollView)
        scrollView.backgroundColor = .red
        
        let scale = item.0
        let kWidth = UIScreen.main.bounds.width
        var scrollViewY: CGFloat = 0
        var scrollViewH: CGFloat = 0
        switch scale {
        case .oneToOne:
            scrollViewY = 64
            scrollViewH = kWidth
            break
        case .fourToThreeHorizontal:
            scrollViewY = 64
            scrollViewH = kWidth
            break
        case .fourToThreeVertical:
            scrollViewY = 0
            scrollViewH = kWidth / 3 * 4
            break
        }
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.frame = CGRect(x: 0, y: scrollViewY, width: kWidth, height: scrollViewH)
        scrollView.contentSize = CGSize(width: CGFloat(item.1.count) * scrollView.width, height: scrollView.height)
        
        for i in 0..<item.1.count {
            let image = item.1[i]
            let vv: TTView = .fromNib()
            vv.frame = CGRect(x: CGFloat(i) * scrollView.width, y: 0, width: scrollView.width, height: scrollView.height)
            vv.imageView.image = image
            vv.imageView.backgroundColor = UIColor.random
            scrollView.addSubview(vv)
        }
    }
    
}
