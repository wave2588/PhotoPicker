//
//  ThreeViewController.swift
//  PhotoPicker
//
//  Created by wave on 2018/12/1.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

class ThreeViewController: UIViewController {

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
        
        
        
        debugPrint(item)
    }
    
}
