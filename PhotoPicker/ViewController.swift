//
//  ViewController.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/26.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

var bottomSafe: CGFloat = 0

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PhotoPickerConfigManager.shared.isDebug = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if #available(iOS 11.0, *) {
            bottomSafe = view.safeAreaInsets.bottom
        }
    }


    @IBAction func click(_ sender: Any) {
        
        let twoVC = TwoViewController()
        present(twoVC, animated: true, completion: nil)
    }
    
    @IBAction func clickTwo(_ sender: Any) {
        
        let twoVC = TwoViewController()
        present(twoVC, animated: true, completion: nil)
    }
}

