//
//  ViewController.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/26.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PhotoPickerConfigManager.shared.isDebug = true
        
    }

    @IBAction func click(_ sender: Any) {
        
        let twoVC = TwoViewController()
        present(twoVC, animated: true, completion: nil)
    }
    
}

