//
//  ViewController.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/26.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let vc = UIStoryboard(name: "PhotoPicker", bundle: nil).instantiateViewController(withIdentifier: "PhotoPickerViewController") as! PhotoPickerViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func click(_ sender: Any) {
        
        view.addSubview(vc.view)
        
        vc.view.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height - 78)
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vc.didMove(toParent: self)
        
        vc.outputs.clickClose.subscribe(onNext: { [unowned self] images in
            
            let testView = TestView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.width))
            testView.assetItems.accept(images)
            self.view.addSubview(testView)
            
        }).disposed(by: rx.disposeBag)
    }
    
}

