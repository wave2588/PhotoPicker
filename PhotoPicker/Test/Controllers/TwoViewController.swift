//
//  TwoViewController.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/26.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TwoViewController: UIViewController {

    let vc = UIStoryboard(name: "PhotoPicker", bundle: nil).instantiateViewController(withIdentifier: "PhotoPickerViewController") as! PhotoPickerViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        PhotoPickerConfigManager.shared.fail = { str in
            debugPrint("fail:  \(str)")
        }
        
        view.backgroundColor = .white
        
        view.addSubview(vc.view)
        
        vc.view.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height - 78)
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vc.didMove(toParent: self)
        
        vc.outputs.clickClose.subscribe(onNext: { [unowned self] _ in
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
        
        vc.outputs.clickNextStep.subscribe(onNext: { [unowned self] item in
            
            let vc = ThreeViewController()
            vc.item = item
            self.present(vc, animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
        
        vc.outputs.clickVideo
            .subscribe(onNext: { session in
                
            })
            .disposed(by: rx.disposeBag)
    }
}
